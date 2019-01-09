Return-Path: <SRS0=IlG+=PR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8AB2DC43387
	for <linux-mm@archiver.kernel.org>; Wed,  9 Jan 2019 16:37:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 45C54205C9
	for <linux-mm@archiver.kernel.org>; Wed,  9 Jan 2019 16:37:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NfJyBJNP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 45C54205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D84458E00A0; Wed,  9 Jan 2019 11:37:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D0A068E0038; Wed,  9 Jan 2019 11:37:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD3298E00A0; Wed,  9 Jan 2019 11:37:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4B0498E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 11:37:57 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id p65-v6so1961572ljb.16
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 08:37:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=hpOd4KOhVWXZ0ZdlLnkpFIAFTQUwdhkSA+jWkyxu/bA=;
        b=mBtE+8W1at9H7Le00k4rNu1VJA9ZAe7i+ZvVTgyGxuY2mM8gH+EAm8jMENGcdYApCu
         al86QcP5jLU5SLByTxt9NHEhYJUpMVH3mFcaYRi4MOOi39NT5qPlcVohQOXCtFUWTG03
         GFde6QhZNtYPiqsNPQ6UpDhBR9097fW3TIAwF88fduUfE6RrdHb+t/jS47ri4Q0FkfOj
         SQaNRt1g1DYsH0p9dk1/QGhTaBZlyq6PbBXA11mcIB9Q46+gzs7GGW9Xs/SD2TSNPRRv
         8dsS/lrwjZWMs7/4dGfFrNrw770DNKGeI8AOZMw+F/gwQHvUkqAmYw7PFmxWkPv5h+4g
         Fuig==
X-Gm-Message-State: AJcUukdMaOnsAkjoUyElikYsqMeL8tkpwXiYUOX1M3j+8Q8AwcAmPASO
	k8+f98PGgE3OjOl1PaXq4cQ9z28vImGGfCA4vqKD+OdeR23N/3nVh1zzdeU0M+LH9QcZMZVx6iI
	KI/Bk58yp4qCLkIR6MFzjEU6fXTeYk7kRoHCf3krqK3HjOWbeEC6qkTfTnRVLNANq6U87tyrVcj
	doeN25hmUSO7dDavjMNu27g2Uvrfnt8EDNjgAbX99JsSodv7GSyiRC/UZ+9SE0pQXKpi9rTMWAf
	w6VIvW3GUsNP54bj1HrRLINf3wYSdRkm4BjWCCt0HZ847/9eTp4XtMyezZrTF+Acvt6kw3aWkTj
	zS3QQr/J/ewji+PwCIKYStls0rf8wnzbM7/fWpg3I8BTsSVXL+LWHZY48hkvBua/POoc4RXqR6V
	K
X-Received: by 2002:a19:2106:: with SMTP id h6mr3798957lfh.29.1547051876608;
        Wed, 09 Jan 2019 08:37:56 -0800 (PST)
X-Received: by 2002:a19:2106:: with SMTP id h6mr3798919lfh.29.1547051875744;
        Wed, 09 Jan 2019 08:37:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547051875; cv=none;
        d=google.com; s=arc-20160816;
        b=uOri/X5c+mTs8Pv2Et/kF7AkDzC+q45w9tTMK2kTR7w2wwV3Lpr0a+ZerDKNa0r9Dz
         uZ30TWOmMp8kaAMsPoqM8Yub8StLS3HgeHV5snDpXn6GuuvNOWmHJAsOoekp1Iuzb1jt
         sE21QDDKy3s3iHObko95XvnGDhXXgphal9dxmxaXTVpok8WTCPaiAm3Sd/TleXKqep18
         +7GfIW34tYTTJQ65RNMbknNuRxX5qbL9dPl/MAJDctcOl+qg03n7L1VHCwskrI2KNh6u
         cI7mrh6LGJAi9kRlgvS9Kl+49Jz0f+o7vfnsNxxcDIN96gbI6MV3nAmN2GQ/G4T/PeOg
         sFCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=hpOd4KOhVWXZ0ZdlLnkpFIAFTQUwdhkSA+jWkyxu/bA=;
        b=z5VJEusZ1KBRBbvAX1B2rd5nHfo9K0nFOL+QVZz6+PlpERw57I80TwyRwYdsQWklVs
         d/kT+yXecWIXvbBWi7bWEEvxHjZ1g9p9xUAL8XJJoVd1st1JilxjumwIbUqL8bjufeE2
         cMUS//hzVo0Lx6RVmHfQ92c8Oknol2qJQzr00AxIYqsvUH9po/KHinVOfm5LAZPKJTbn
         WLrk5+q0YVuaaEKk7xHPEl0X71tSNPauUtpiu19Ku7gzidQRUXHXD2SrUDBNn21X2FJC
         +kYBjGJobRST4Asm2cU3Hrs7nkCx97yL6EEZSYfZaigpJboURGMfahbwjo5rPDz+R8uZ
         4POA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=NfJyBJNP;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 142sor14010047lfz.23.2019.01.09.08.37.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 09 Jan 2019 08:37:55 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=NfJyBJNP;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=hpOd4KOhVWXZ0ZdlLnkpFIAFTQUwdhkSA+jWkyxu/bA=;
        b=NfJyBJNP+A2pxkF+NsTb0axj1JVmsIGePDLjWasCKbvY5Oeo0W/6duHA2+9VddhYlW
         8bP8ubvLP90Vd2INGZACF6/6xTGGxLbW9gk6uTzoCrnEQv83HfuR2hzwoPYd2VA3BVcH
         yaijCSepdsAun5H/62Z9sg/AIE2NEfT4xpGIKQuAk2TN/CCRgx5zJ8NmaeGe2BxP1OOg
         UTZ8z0MiecvrSiMijqhYWg3qYudIctW+LbS6YGn3qLpwVKWn/wC9kUf8WHj0wBf2BoVI
         ajpecRIoc11UA+gqFAEo+eJLNhmRJuLz3LlnEEXgULyF9Tk/k32e1KELSsNI/8OC6VKp
         Trtg==
X-Google-Smtp-Source: ALg8bN7HYEAYVDhoJOy2VZl/oQu8bMNl9nvj+Z6fTXvBgWBdK7HamubHUq6qaP5uvlNe/+zZI/XNJBIbvXNw/KI0T8A=
X-Received: by 2002:a19:2906:: with SMTP id p6mr3756886lfp.17.1547051875267;
 Wed, 09 Jan 2019 08:37:55 -0800 (PST)
MIME-Version: 1.0
References: <20190109161916.GA23410@jordon-HP-15-Notebook-PC> <20190109162332.GL6310@bombadil.infradead.org>
In-Reply-To: <20190109162332.GL6310@bombadil.infradead.org>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Wed, 9 Jan 2019 22:11:46 +0530
Message-ID:
 <CAFqt6zYQU+jN57Lh2Enx-t9EKHSjSKibUHU1Y-KyzAzxWVy3Qw@mail.gmail.com>
Subject: Re: [PATCH] include/linux/hmm.h: Convert to use vm_fault_t
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, jglisse@redhat.com, 
	Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, 
	Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190109164146.D0reyCLGi1L2hJQIg1JXeZ9hkpcs7YkXZFLp0xGuq3M@z>

On Wed, Jan 9, 2019 at 9:53 PM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Wed, Jan 09, 2019 at 09:49:17PM +0530, Souptick Joarder wrote:
> > convert to use vm_fault_t type as return type for
> > fault handler.
>
> I think you'll also need to convert hmm_devmem_fault().  And that's
> going to lead to some more spots.

I will add it in v2.
>
> (It's important to note that this is the patch working as designed.  It's
> throwing up warnings where code *hasn't* been converted to vm_fault_t yet
> but should have been).

Ok.

