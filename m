Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AFA93C7618F
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 20:36:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D1EC21849
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 20:36:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="lUOwsJeO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D1EC21849
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A1E56B000A; Thu, 18 Jul 2019 16:36:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1525A8E0003; Thu, 18 Jul 2019 16:36:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 040048E0001; Thu, 18 Jul 2019 16:36:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id C29176B000A
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 16:36:28 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id d6so14501702pls.17
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 13:36:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=0iWfPZiED2y0HXKCmRt4vCAoYhzxrMk2HvPK+JT9VQc=;
        b=Al/r9fcdlhfMn/WuYdCsnRkrXtXk4QhtD3JkxxsWTquy1NyZqtAYhw2hHFkfpXwmNL
         /ZPporAgPoAJELsiQJd8FG0jaFP5i4Psg96TjQ6CbtsU7cAzBKTGN2bBGZy/q+ktDqkj
         LGYZqf8bjgGHGaMMtoPt24GOHB3ZqKU4AubZctuT/G9DLuuTXVfADlYeKCQ8PxRFmYqL
         3+/PBQrNfHZp0uTNLvvoecTrSpDNTh+g4dK1hsSHhHCt3USnOk1PMnW5IMwzRGXWY/VD
         uLLITIi8pEU4qtgeIJqLA4W8pQbuPseQ4IruLRd05mnpp2cGMuc3DunuTx4sdGZ+MX7m
         fy2g==
X-Gm-Message-State: APjAAAW/3Rfu8GahyPJ1tYmC91rPF8TPJME/zMI4ii9tkvfMx8vN/OYw
	t1X2RK9zkb+Z6jx7fvAKD+U/7dD9/q/JtTN0LmRr8+r4LUrtCYUgt2s87ZijF+eSYKNtyqp/e80
	8fwqjiMNQ8PMoQPOh+Q355Y3Cp+jlvBtJ4O/Ft52g0aSf1R+2TrvbN1vTBahHZufqPg==
X-Received: by 2002:a17:90a:3544:: with SMTP id q62mr53727154pjb.53.1563482188357;
        Thu, 18 Jul 2019 13:36:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqynIxnliM+0knIic7XBDs1rVIHBDUIH5frheKhUei5hCm57rn3rTcPKnN/MkMyrZ2i+O1Ve
X-Received: by 2002:a17:90a:3544:: with SMTP id q62mr53727080pjb.53.1563482187697;
        Thu, 18 Jul 2019 13:36:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563482187; cv=none;
        d=google.com; s=arc-20160816;
        b=Dy1QffyBiD0CMwWVl6u1JPlI43my9uM3KLHIB4WuQ7qBnJj7GBWDE3WvRHdmxTVr8y
         O4XxXSWql0KgiUQphLLpXjTYNnZJTr5Mj+q/TF4RTQQLYao1lYO58k9ZfkrxvW8d/K32
         IkEFmSfMrMGabRylC3Yb5S0wcHOmtrRVkNPgbEO5MWNjhKjktK7IJq6BvSECG2xVIO8h
         9wun5MTENYHnfUdNFufacV+MtLY+wPn0NJK7HhYmyfz+/z8oEVx+S4hZGZUkQAsksVVt
         tQBtk9TyVHr99iJrTLiuZqbTFhDml10ABXZMp9Mgor5o8iDfZszF8YJUbkFNhGwZ+LXj
         dCXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=0iWfPZiED2y0HXKCmRt4vCAoYhzxrMk2HvPK+JT9VQc=;
        b=dNxB+XwUoXFki6cQrpwgBhISiYiOtpZjSvpYYdduCVqhV+3ZaPtLBTTwA4GVyu+09z
         WKMnPCeE/FowCcXlI4PLsTsmMndtldV5bYW/Pxv3QhqJjSQWEPw68fiynU4Ztwo7EBaX
         6J0sJNi7j9b+bdhav2/z8LGstbCluSVEe6/+YPi1ymtssfHtxBETRmTa6Y5DkAni83BC
         OvynwLn2piGOZhRkUZuT/C2Ov5rYsBHuvNVW0kwBAlAKlzHzv3eeVtXn6xGitAImjXVn
         Vto0jh5KC6E7FxMEiRamQUKeDrUKfcsY8RgP+p00umDJo+dw0MVdhVolZ2faj98C6WBt
         0dFA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=lUOwsJeO;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 145si303659pgh.320.2019.07.18.13.36.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 13:36:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=lUOwsJeO;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.64])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 9D45A21019;
	Thu, 18 Jul 2019 20:36:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563482187;
	bh=n33RnYgEWXmqJNz9rAt/hhFEfid9BuR/+DJfKxYaK0U=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=lUOwsJeO09VcivQzELIEb1xspaeMrv8igfqpVje7IjB8d0vzktO7JZSGLFIM+EfTr
	 h/bHRCTZ3vQJKeX3CNOxKC0fE0T4geSoEIcdsi2HhD4Y4RNcoErz93W0ItzQFE/qdX
	 vMDMu7ZP5PtAPbBp6eeXNJtHCfHbt5jrTeJLUhF0=
Date: Thu, 18 Jul 2019 13:36:26 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Wei Wang <wei.w.wang@intel.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, kvm@vger.kernel.org, xdeguillard@vmware.com,
 namit@vmware.com, pagupta@redhat.com, riel@surriel.com,
 dave.hansen@intel.com, david@redhat.com, konrad.wilk@oracle.com,
 yang.zhang.wz@gmail.com, nitesh@redhat.com, lcapitulino@redhat.com,
 aarcange@redhat.com, pbonzini@redhat.com,
 alexander.h.duyck@linux.intel.com, dan.j.williams@intel.com
Subject: Re: [PATCH v2] mm/balloon_compaction: avoid duplicate page removal
Message-Id: <20190718133626.e30bec8fc506689b3daf48ee@linux-foundation.org>
In-Reply-To: <20190718082535-mutt-send-email-mst@kernel.org>
References: <1563442040-13510-1-git-send-email-wei.w.wang@intel.com>
	<20190718082535-mutt-send-email-mst@kernel.org>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Jul 2019 08:26:11 -0400 "Michael S. Tsirkin" <mst@redhat.com> wrote:

> On Thu, Jul 18, 2019 at 05:27:20PM +0800, Wei Wang wrote:
> > Fixes: 418a3ab1e778 (mm/balloon_compaction: List interfaces)
> > 
> > A #GP is reported in the guest when requesting balloon inflation via
> > virtio-balloon. The reason is that the virtio-balloon driver has
> > removed the page from its internal page list (via balloon_page_pop),
> > but balloon_page_enqueue_one also calls "list_del"  to do the removal.
> > This is necessary when it's used from balloon_page_enqueue_list, but
> > not from balloon_page_enqueue_one.
> > 
> > So remove the list_del balloon_page_enqueue_one, and update some
> > comments as a reminder.
> > 
> > Signed-off-by: Wei Wang <wei.w.wang@intel.com>
> 
> 
> ok I posted v3 with typo fixes. 1/2 is this patch with comment changes. Pls take a look.

I really have no idea what you're talking about here :(.  Some other
discussion and patch thread, I suppose.

You're OK with this patch?

Should this patch have cc:stable?

