Return-Path: <SRS0=ysF+=PT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ADD89C43387
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 18:12:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6364220870
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 18:12:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="gdPVx15h"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6364220870
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E67958E0003; Fri, 11 Jan 2019 13:12:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E15858E0001; Fri, 11 Jan 2019 13:12:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D05798E0003; Fri, 11 Jan 2019 13:12:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id A95C58E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 13:12:39 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id w19so17440355qto.13
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 10:12:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=/faNOUmzdO023/qiPPvya8217BgcMHSLrRb/VXt8ZY4=;
        b=WO+hGurKOfqdu0Na3vlDmMHBkzb7m5A/sbqGrm91k6XqqkSbP4dOBbh6J9zRVnb7zk
         KD+rJmyEGhD6E/NQq6ggkO8XkSoQG4ct2wAY03dGm0GtlkB7WpfW4pIxVyhix2ssAK8a
         zHZ6JMbBAuOzXazA3PP6qtflutDn7ah3hZfuSaK+Pp1AzokM/kHI17/Bhhs3c8dRV0PG
         tGmeDc2KTe2Fb8FuUPsISRzIbpIeOlDSU9tTOi1ddOt0hH+zygUgYxq/gFjBvGi+XI3J
         OCGLBbKt/xklCWZxf48kiM/JehfilSBN461aOBFiAiVi43i3VeJwd3OsLfOW3LT/PK+G
         5tMQ==
X-Gm-Message-State: AJcUukcUOrkK6OQ8cbhlGY6GgEQzCH5jweXPDA2+CvKrmz3+B7lGmSFZ
	6vz59Rwt8/D0JuMry2jlBANFzJ1mtYzBeVuQ6+AZKk6tgeV+33wv8B/lJ6KqTB3olUtIYR7lPAo
	P0tHssXWPQaef6haBkCGPzdJPvMlY7ZWC4/q80T5UVa7R07ImqgGnWSQ3GtIzr9Zv9YfHjKzmc3
	JpqFuVuRXbB6veMFfZ4N7d/O6YqVoOLNDZX/pHAChLMEcOMsTRkNzH55n3lp5I1N3rYvlVcVyyT
	w2IGzn1WmyVHHCWKioO52S0hrgf80WfUMnHaqUhDpEOewsujq51QNFNksgXYXj4Q47meVM+Enzl
	JeufYwGeXhG10Z9aDiNIow1llbOt7BO3qFksubg3nfaNvE3jaQue85Y7kzVkyxzLfYCGttQ7r+c
	T
X-Received: by 2002:ac8:36ba:: with SMTP id a55mr14471302qtc.236.1547230359411;
        Fri, 11 Jan 2019 10:12:39 -0800 (PST)
X-Received: by 2002:ac8:36ba:: with SMTP id a55mr14471271qtc.236.1547230358920;
        Fri, 11 Jan 2019 10:12:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547230358; cv=none;
        d=google.com; s=arc-20160816;
        b=uZ5cowsFO+Ytc7z6LlSiw/q9l87D6fPUGqUNX/A3Fc0S5wHWvBKH3vMZzTkYKe4CbW
         z2BxQHAJHh32qb4hcJ/eKfpCwWCUKTRTdiTtlFZI4Ac2+N73SmdhvfM7OV93RS2c/vLp
         pm2+tVZDzvIiM7uvcaSXxsy+FS6ZPa39ieyef3ymW6B3g0pd/KZIq74rwPIAFNXHPdJS
         Z4AyDflUsBIdDY7Lf/yMVKixUrFOrTz2IkkPKjpNfObVuQZTx/xiuA77OMwfInOzaNFS
         d6BB5ysNNVbmr9zTMUHx0EisI5J1U8zXlKBnev3AU64kG5Mm5cwNokqPmetrudCFlg71
         AixQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=/faNOUmzdO023/qiPPvya8217BgcMHSLrRb/VXt8ZY4=;
        b=Xu75AF3lL6oaIt6ZrzscSx95NIpHEwWt+VsBlQkZzfNm3RzLe3xYvXUE07lZp3sDea
         AJ0i/gBPXPqznTAQm7iFkmZITVewXjxmVUYgjbiUynNNdMT14Rzrd/imvbGpHxD0WgSl
         3nig+LGP/PxKgUCKFVFvQNaVbK1ZdCXf9V0OquV3OSJe1qQn3q0hZimvMIAw85w+b/su
         7yr0j1FuzuocUTorDHHPtzvj/7dSPgyaSTMT+/D64b2lQV29GMz//2ahZaiAp0Bv8xzY
         ZkXMkNnzmaN3zxtis5IHaR5drdi0U6Eetb1UwLlslm1OC8sDcfTqJRjxBYkSmXIjGdhM
         PvPA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=gdPVx15h;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q17sor76112401qtc.32.2019.01.11.10.12.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 11 Jan 2019 10:12:38 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=gdPVx15h;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=/faNOUmzdO023/qiPPvya8217BgcMHSLrRb/VXt8ZY4=;
        b=gdPVx15hHseBGGCZOUdjz0yeoaTlruoMNKfOAXWY+xRYvGd7sRhEtmR7NS9tSXFIkj
         qf3QC6D3nDGGG2IrhJ6aZ3noFrzA0/Svo5blkzb1wp6ll6CEhfYFrkDwibLKmaIPuSid
         LMoTLg9abUVZpSPA/6aGZHe+RovRlwueS0WT2cytsnIqjsbyG/j1ZIF46qiOs3UbbxJl
         3W27aMYcQ0z+X1ZchE5F5M5c9D0DQUnt37Lq9Q5RUPjcbBdQDiatVqfLmvs0vnwr6puL
         sKDfG2LTl3NWbJW+f4ifsBf8sKNLw1kHHeSA2fPNUA/BoU/eVwzedJ1vKWHB0pmp+K5G
         M4xg==
X-Google-Smtp-Source: ALg8bN49eg+xjlGxb/eQ3GdLrp3F1VZNrPjZ9Uz2+2vzzBiQrfxejzlh48d2ckGvBkfT+WoaPRtvBQ==
X-Received: by 2002:aed:26e1:: with SMTP id q88mr14659000qtd.148.1547230358612;
        Fri, 11 Jan 2019 10:12:38 -0800 (PST)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id w52sm47628307qtc.51.2019.01.11.10.12.37
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 10:12:38 -0800 (PST)
Message-ID: <1547230356.6911.23.camel@lca.pw>
Subject: Re: [PATCH] rbtree: fix the red root
From: Qian Cai <cai@lca.pw>
To: Matthew Wilcox <willy@infradead.org>
Cc: akpm@linux-foundation.org, esploit@protonmail.ch, jejb@linux.ibm.com, 
	dgilbert@interlog.com, martin.petersen@oracle.com, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org, walken@google.com, David.Woodhouse@intel.com
Date: Fri, 11 Jan 2019 13:12:36 -0500
In-Reply-To: <20190111173132.GH6310@bombadil.infradead.org>
References: 
	<YrcPMrGmYbPe_xgNEV6Q0jqc5XuPYmL2AFSyeNmg1gW531bgZnBGfEUK5_ktqDBaNW37b-NP2VXvlliM7_PsBRhSfB649MaW1Ne7zT9lHc=@protonmail.ch>
	 <20190111165145.23628-1-cai@lca.pw>
	 <20190111173132.GH6310@bombadil.infradead.org>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190111181236.AzeF7BkjgQrV_OT6_TGq2FPAxp1cy7KuALWVfudAG-s@z>

On Fri, 2019-01-11 at 09:31 -0800, Matthew Wilcox wrote:
> On Fri, Jan 11, 2019 at 11:51:45AM -0500, Qian Cai wrote:
> > Reported-by: Esme <esploit@protonmail.ch>
> > Signed-off-by: Qian Cai <cai@lca.pw>
> 
> What change introduced this bug?  We need a Fixes: line so the stable
> people know how far to backport this fix.

It looks like,

Fixes: 6d58452dc06 (rbtree: adjust root color in rb_insert_color() only when
necessary)

where it no longer always paint the root as black.

Also, copying this fix for the original author and reviewer.

https://lore.kernel.org/lkml/20190111165145.23628-1-cai@lca.pw/

