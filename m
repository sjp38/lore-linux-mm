Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A63D5C43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 15:34:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4F18520675
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 15:34:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="VuvgGIEY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4F18520675
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EDC456B0007; Thu,  2 May 2019 11:34:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E8E2E6B0008; Thu,  2 May 2019 11:34:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA26D6B000A; Thu,  2 May 2019 11:34:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id A39746B0007
	for <linux-mm@kvack.org>; Thu,  2 May 2019 11:34:49 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id n10so1388077pgg.11
        for <linux-mm@kvack.org>; Thu, 02 May 2019 08:34:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=GGdylbHYZyR2qm2vdfxGvLD5vmPq8suNsN+FzC+g8Nk=;
        b=A897unGqCuB7Abhw4MpXtAjp7vDR2nnJZreXT+UUDZOwsfy387WCUjBWBCx0duZHrD
         HK1FIq7eJ403Pm8pJk/aGb1AXImRDSzVgf4hbCv7hLax02z40ieoyCsXCpL5pKRjUPKj
         jipo8lwAWT1tQ/+Gp53ATapluPJpkY3FPpVoeNGWwP430IoIYjAeUYssdvUJacc6/8ni
         N96XND02FAaYUoDXzi4zZioobJXl/2mo8oI9F6/DPiDaM+xvwcFIKz4m9fIVtHSccGM0
         wtYiGLvjjdwbQklD2qRX+ZfFQz6BdyNAZXTP4/R0wQ9TD0HPj6JNunl7f4hbdbJW5GEw
         IhEA==
X-Gm-Message-State: APjAAAWscyO/DqOyWte8EVyg92LCNdly+POEZG5zD+k07TAa22vGgjZn
	ZNbVWqiD9K35pQFmm5mfn6DaVYaY4gzTKQzSFA0jgGn1VbA9tBfS5n55SeEYa/XFmqIeLn81G9V
	EkEfhNqcM80sRwTyQsvY9I42/A7XEKweEY9/zeGSS5aBl1C6ICcL6RbyxTBKSpLeXjg==
X-Received: by 2002:a63:cf:: with SMTP id 198mr4489508pga.228.1556811289305;
        Thu, 02 May 2019 08:34:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzRRWz43jJeYpGaMxyn2yl/O/WOI9Nphk2G6X7rS4/IcR4wY7Ol0DOItazX32UbyOkYUFUb
X-Received: by 2002:a63:cf:: with SMTP id 198mr4489439pga.228.1556811288548;
        Thu, 02 May 2019 08:34:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556811288; cv=none;
        d=google.com; s=arc-20160816;
        b=ImLYaWnb47j7Sz8Ckhs9VmdWQj8OQnMynzdhTIEMlojbHjb+LIAHWSkucoGKjUlkd1
         +oMwP+xF+anllCQYVvnXWj7bkwrm4zfF8FTbVbSwXaA+ix2Z+7KMX6EUDuS3FmsWNoLC
         rJJWCqzaSfXkp/OwZ2MAssBiP8eOQzS57M8dhi6r233kvnkM3HBK7DZkQ2yPeGVKoHFH
         GxxD8nRY5tm3wO1FaGuKGQX07zeEoyxHBQNTa+wE8L4aaWV8mFjemhCcD+RolRh3FKb/
         sa2TosPYcy1J/Klg7RKmHoOqYduuTdGj2+05IvypMsRtihg0eO5RVWNYR/GJ6egDLqlg
         EphA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=GGdylbHYZyR2qm2vdfxGvLD5vmPq8suNsN+FzC+g8Nk=;
        b=V9T5m9dB1JIg+6Hb1oIGVnbLSBarqv1GWZ1tW+QkL6eNyWDTrxj3G94WfsYV9LqS0V
         JJqG7fG4biOlfhb5JsqbUiNGtIhOsVO9rAk1auwGbepEpW9QI6aZe0nw4IzpNO1FZUYh
         Wy4N+XDbkpSuukEk7WceekNYURTuOIvKDOhZf6Ef4KmuzUzmdpOE5V5EAj6yIACLk8xO
         kfPGhBi7wkUiO/c0QzjBf5069u2qOSTg/hf0TBWnMHHYAJiMbz5yEr7I7K+QEOLuvCf1
         jqQu2jdntYJedzgOQKjs6DHhTAxIgB8qVMvjsyM7fWev5OmBC+5sSByOJXbFhfvlvrEi
         qbsg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=VuvgGIEY;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t38si3637530pgl.497.2019.05.02.08.34.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 02 May 2019 08:34:48 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=VuvgGIEY;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=GGdylbHYZyR2qm2vdfxGvLD5vmPq8suNsN+FzC+g8Nk=; b=VuvgGIEYbnHU4FkDuP3pNCt3D
	+FScHu5plMnaYj3Mn5akglhBotjQ784lC2SwzTWixP6XM0habM8FJUARPvywBs40W3TIJERp3AHxD
	Zxqb1D67UBN5p90bhAGZ1gun2Am5p43wG0tdInlVntMere16K4fOwAG8tCsKM146rJXuwe9i+CkXj
	p8BmBY9YUbVu34ABQrZsCPZBiNmMoVRqFC3fnsrj6x2kgn43E6hBUIhsYJIv2jDF/N7Ensgbwbmli
	AaoGCH7sPt9q1t50IpQvArDChfQ6ujNY/cfK/LYNnfRAwMozL23NczSmpV9wCfAguAkeUOUaR9Oc7
	L0tpOtcDg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hMDjS-0006tx-7F; Thu, 02 May 2019 15:34:46 +0000
Date: Thu, 2 May 2019 08:34:46 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Jan Kara <jack@suse.cz>
Cc: Jann Horn <jannh@google.com>, Linux-MM <linux-mm@kvack.org>
Subject: Re: get_user_pages pinning: 2^22 page refs max?
Message-ID: <20190502153446.GC18948@bombadil.infradead.org>
References: <CAG48ez3C11j5On4kqwSBCZGtpS5XMohwEyT_2ei=aoaTex7D9Q@mail.gmail.com>
 <20190502014422.GA8099@bombadil.infradead.org>
 <20190502152439.GB25032@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190502152439.GB25032@quack2.suse.cz>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 02, 2019 at 05:24:39PM +0200, Jan Kara wrote:
> On Wed 01-05-19 18:44:22, Matthew Wilcox wrote:
> > On Wed, May 01, 2019 at 06:19:00PM -0400, Jann Horn wrote:
> > > Regarding the LSFMM talk today:
> > > So with the page ref bias, the maximum number of page references will
> > > be something like 2^22, right? Is the bias only applied to writable
> > > references or also readonly ones?
> > 
> > 2^21, because it's going to get caught by the < 0 check.
> > 
> > I think that's fine, though.  Anyone trying to map that page so many times
> > is clearly doing something either malicious or inadvertently very wrong.
> > After the 2 millionth time, attempting to pin the page will fail, and
> > the application will have to deal with that failure.
> 
> So actually, you can still have ~2^31 *normal* page references (e.g. from
> page tables). You would be limited to ~2^21 GUP references but I don't
> think that would be a problem for any real workload.
> 
> If we are concerned about malicous application causing DOS by pinning page
> too many times and then normal reference could not be acquired without
> causing issues like leaking the page, I think we could even let get_pin()
> fail whenever say page->_refcount >= 1<<29 to still leave *plenty* of space
> for normal page references (effectively user could consume only 1/4 of
> refcount range for GUP pins).

Oh, I haven't explained the page refcount solution properly :-(

After the page refcount gets to 2^31, no more get_user_pages() calls
will succeed.  But normal get_page() calls will succeed, so you can
still fork() or do normal IO, just not O_DIRECT or RDMA.

I wanted to find a solution that didn't permit a local DoS by, eg,
doing O_DIRECT writes from a page of libc.  I mean, you can stop other
I/O from occurring, but you can't prevent fork().

