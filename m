Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C20C5C282E2
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 21:41:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6C9B721736
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 21:41:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JJcZSD9H"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C9B721736
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2BA266B0003; Fri, 19 Apr 2019 17:41:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 23FE96B0006; Fri, 19 Apr 2019 17:41:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0BB406B0007; Fri, 19 Apr 2019 17:41:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id CF5F46B0003
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 17:41:24 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id d1so4102066pgk.21
        for <linux-mm@kvack.org>; Fri, 19 Apr 2019 14:41:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=sgVFhxDqfVPVv96StH2CfU6FG0N/pAfm/sn71zUxjIY=;
        b=O2sMwpAniKwgvXuIUqOQf8m1tPewMRvWkCdtKWIEyvalEH9EQEOOI+q7w4fJvKu3Wj
         nWRMdTxQ7b6Oq7wjEzdD+BsqqXAxI14p66V2vmO9A7F08e8dndmFlPzq4DHMwi8vUVHn
         fpCtTF/G4okRu9VoISfNkhITHom3523Nzre59SknVJ2O+jwluPms8SrfRMbl0SaPewoB
         QAopvZ+1dG/bkwFiz5HMWOinGcpSQATAl3U5xE+jstS6HUY0+XkKj3ECDpusGh8iRW7h
         2OFGgNEewcgAOBVOClZbqz/zBK1R1QVmUAmu4foU6w/i2t4kot+JjMMOSGQyngVNs6S8
         g8Iw==
X-Gm-Message-State: APjAAAVYVCkX8fC+PugfxAxc4cEGSuGpSoOT4j8Q/2kBe0bRrhK0dahD
	UCBL93FViBPY4WqzBMv8bH4V2w/PdqnxM6HR4HtV6zIe3WDZn8ZAbxCQNZFscKb0dzJsc56tBBS
	RZVmcrB7Y/UGp7MTn0Gc3RR1jZ+8K3VXX5wwtTeEffMUCloAtzF+dZeO3H9xcJfYOsA==
X-Received: by 2002:a65:6144:: with SMTP id o4mr5907657pgv.247.1555710084497;
        Fri, 19 Apr 2019 14:41:24 -0700 (PDT)
X-Received: by 2002:a65:6144:: with SMTP id o4mr5907610pgv.247.1555710083566;
        Fri, 19 Apr 2019 14:41:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555710083; cv=none;
        d=google.com; s=arc-20160816;
        b=Btyj5zvSmlueFOug3QSjMk1PhVE5laOtPdAMG9B7/p2DCikgzqGc263y7Vy30N5okk
         kNEllYu0VXgGRUPUrRuuX/j1xC8c7pAkV6y2xJ/uobmqDBzp2lXfEd87xN3KuEHyPPzn
         6a3LRW5uagLtRSVRWb13cu2UfVKWPvVagHFcLreNjdZIP/nquT7k+ChlZ4ItRNEMfkDw
         LdYSVT6TUUOJ0vzwh8vzsa6wdwb2d006WR2/DVkrzGC0WI8XkQLun6RoFQkxUSz6L76U
         MFtHwOVPdtwN2dH3bnskOVVqzPfdcPUHghm/VFETL21ia1HUsmMTDy+QLWTQB47EmMhH
         5QrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=sgVFhxDqfVPVv96StH2CfU6FG0N/pAfm/sn71zUxjIY=;
        b=qMtAac6k1v58J/D5hXEEfPoq/G7YQn+bH8yubHQ6BSupfBLiRNnLxRXZFXigkK1Nu0
         06SdESmvvqWPSO2L6/8JxbRt9QerBw5+Pwh47tfOR31V4lIh4IVEz7ET8smiQZsbMIkQ
         w+BRZHdRw9OINCNReMfUWChdkQ+EmhRlxiLescA3jXXusI46RJ28WcxfrclXLsPDuO5e
         71X8KBl5R02mU2zb+ZcybhnV9W8LF0asr9KXrjxJHU957kZehG6rAJwatsa6n6oBhcML
         dZeXD5BAlFhIuH1WWQ/1HAF/snH0D24kavSz/yJKFSY1bg8tXS49f3yCbXT5fRSNpBid
         0gzA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JJcZSD9H;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g2sor6471175pgl.60.2019.04.19.14.41.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 19 Apr 2019 14:41:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JJcZSD9H;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=sgVFhxDqfVPVv96StH2CfU6FG0N/pAfm/sn71zUxjIY=;
        b=JJcZSD9HCJpk2lu5iLVZIC+3fTiDv8Bjc3UmntHTEF3tLjbapQAqffVtSxjTXk1gHq
         6bf8pML4ImHVYuV6pjOmJ1MTLQUMVn26F0Q0J51cEl/fmxMoj4qNNJT+Yk97NPSIgFuq
         UuQgMYWBbLncGrglRNTlBS1fBXdjvSGCiC00pVWbeszmOIIv2ol38pQqwUTOh5n7GuVh
         +cluXSuV6f86CDWtyVtS7ScX5x5ot4fCQunxDa5HA6uoCRYssq+OSuaZSQgBKMKD2ahR
         mu3sfgf5XYfNVI7Vr/wpoOaN7EBYFpvxhe0ZSAXPamsCQpcbkFmp8/0qpnfyZ32IDHj0
         fHUQ==
X-Google-Smtp-Source: APXvYqz/sp8H3x86xArhlg636ZCPLDazcHqtwg/NBWqTeB/3SaxESSAc1piK3NoUeRZU5NWKhR6+qg==
X-Received: by 2002:a65:5c42:: with SMTP id v2mr5914874pgr.360.1555710082873;
        Fri, 19 Apr 2019 14:41:22 -0700 (PDT)
Received: from [10.33.115.113] ([66.170.99.2])
        by smtp.gmail.com with ESMTPSA id u26sm8024245pfn.5.2019.04.19.14.41.20
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Apr 2019 14:41:21 -0700 (PDT)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH v2 1/4] mm/balloon_compaction: list interfaces
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <679D6F11-07D7-4227-9D02-41F9F8901E61@vmware.com>
Date: Fri, 19 Apr 2019 14:41:19 -0700
Cc: Jason Wang <jasowang@redhat.com>,
 "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>,
 Linux-MM <linux-mm@kvack.org>,
 Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
 Pv-drivers <Pv-drivers@vmware.com>,
 Julien Freche <jfreche@vmware.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Arnd Bergmann <arnd@arndb.de>,
 Nadav Amit <namit@vmware.com>
Content-Transfer-Encoding: 7bit
Message-Id: <5A5146D6-9BE3-4240-BEBB-FDA5BC536E96@gmail.com>
References: <20190328010718.2248-1-namit@vmware.com>
 <20190328010718.2248-2-namit@vmware.com>
 <679D6F11-07D7-4227-9D02-41F9F8901E61@vmware.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
X-Mailer: Apple Mail (2.3445.102.3)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> On Apr 8, 2019, at 10:35 AM, Nadav Amit <namit@vmware.com> wrote:
> 
>> On Mar 27, 2019, at 6:07 PM, Nadav Amit <namit@vmware.com> wrote:
>> 
>> Introduce interfaces for ballooning enqueueing and dequeueing of a list
>> of pages. These interfaces reduce the overhead of storing and restoring
>> IRQs by batching the operations. In addition they do not panic if the
>> list of pages is empty.
>> 
>> Cc: "Michael S. Tsirkin" <mst@redhat.com>
> 
> Michael, may I ping for your ack?

Ping again?

