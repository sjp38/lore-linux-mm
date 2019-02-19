Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9DB7DC10F00
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 14:45:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C95A2146E
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 14:45:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Bg+NNfXr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C95A2146E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D4CA68E0003; Tue, 19 Feb 2019 09:45:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD2708E0002; Tue, 19 Feb 2019 09:45:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B4EFC8E0003; Tue, 19 Feb 2019 09:45:02 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6BBAF8E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 09:45:02 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id e5so14421053pgc.16
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 06:45:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=21DHr+RSj+xLDKfUOmmwQEe9U8Yhv3wyd3vmDfQBbJ8=;
        b=TaPYu76Fy88R7Kb1s7aZats02fk6BMNjdVM1n4mwJWBib41ML/CC3E0kw208HzS63b
         RpfvlBd3HHb/oKwsMJtD4JBkmY8lLbIXaTQklyjqQAm3GuoypHjtRpy6tBZdy+//W39/
         QpfH4PGWsQPICdtH1XKBUEwNqkNbIcwUNRoCB37nxPEPwy9NPBUgbcGZi5z1cfX5sp0g
         cpj/draQeSv/fdpX8mDITFrk5GOka9axI8BtpMT9C9AjXcsJJPU8F5nu1k+qCd5mn5SV
         5MOK0mVR3+Ihm3nyOwcdl9HU78wXPlPM7SLMLI7dOScpScxRr2GDBIYkYdJ/lNApFQyo
         ObZg==
X-Gm-Message-State: AHQUAubGhrkmYL4kuRcuTJLf8E5zfb1w09zNsTLo60z5zSAcXDdMJvjQ
	vF7HobmyxvvtAfsuY8fSLu7dHtKgoiUn2EmNNLxI9VXIEPiiQyFECPsDyO7B++vsETZlI96Qvc1
	4aJNda2bbMZ0MsAvzIlm+eUxdx5bUlzBMe6e7Pf48kbX7tId8vWvO+DPdInWsSe3Tog==
X-Received: by 2002:a17:902:3143:: with SMTP id w61mr31934626plb.253.1550587501954;
        Tue, 19 Feb 2019 06:45:01 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZdw1TAYVpoXPX93VYeCxU/obbnYfVqR0miqxeRFoxe3iIF/kyomoNa5318KjL1Da8fHhOO
X-Received: by 2002:a17:902:3143:: with SMTP id w61mr31934547plb.253.1550587500887;
        Tue, 19 Feb 2019 06:45:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550587500; cv=none;
        d=google.com; s=arc-20160816;
        b=cbfSZhrOAjYE9IneRXHH7sS/97PeMKWyH74bLeA2XsVVr6jpPPcEeUP9ID6Iz8cUU+
         1B5XLIUG8tCNQW8oxrbjto5e4InQXpaR8gxSGQRshJG6RazNwT6fLSIw1N25eko3B9Jd
         VVntGfRZHD8eJyAzKZvzQ7kfkSL+41pNo0JtryEq9EPGPbSUQC7sSQ34mMNCwELL7Rvw
         EBDj6UYI8g9RtBZfeiDcqzZIS8QYjjL64qUuLA2i4hAijsszrE4EGLagfDGY3VhNzorE
         3wYEZZ4gSJY0bIqLlSZq4u1r3H6GaPOfzkEKAuyGyKMF6ux7FhHFpZce2KjZ2vE9laUD
         aObA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=21DHr+RSj+xLDKfUOmmwQEe9U8Yhv3wyd3vmDfQBbJ8=;
        b=cibHrFMU8IE2A20R9HXmNw3WH3hJG94n7pYW7vd6KWx9mZ3Ux+uZO3QNXmqfQeZxxp
         Ge0MJtjd9TGNIXVecXN4tnDzzXFb3s7d68Hq+vvQgnf9IeSt7ygxlYsUrAK52551MyKU
         +NE/aBZ2A2Khv+bqkh72/pV3Zy7os7toNz5XtUf5uK/0z+DlKEbEYT/MHnO1QnjybMya
         soPhAvPDkw/KxQ46YN/nBN6+2HZODt5ZUPHx6XOzOnX3U9MdTcWOzO4kRT9Qwq8v+pm0
         Jpg74WVhAvhZywZmsFQWS4eXyvBXY9/ysfyDxZe81pfr/Rsx4G7Vwyb65F7gAqzBZMbW
         ItQg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Bg+NNfXr;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d25si15972005pgd.88.2019.02.19.06.45.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 06:45:00 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Bg+NNfXr;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=21DHr+RSj+xLDKfUOmmwQEe9U8Yhv3wyd3vmDfQBbJ8=; b=Bg+NNfXr8pMNxktAjX0ExkyVv
	lOVOoBcOoNUemoyU0nqmdAKULhDXV51CARXuwixN51/frSvDKHAQyC9gWmOcQUKqwf2LBzaECW/v9
	5T6e7ypytKZM1hjJQ5+vIH+M8S3EH0yWq0te02Qz3+j4NRy0KO+Vj8f+QrbUEO4qRquWe2sd0K4uM
	29InieQC7y/wRfX+gkc/3SA8hQLf7Dk4jUEnQIR7wCmC+fR3QcDWxZGBHnuSnL5fxuP5FEtyfNNWs
	wYYKgm3NuUkjYL6QAE0DtVmUV+Le0h5If2nKRN/8DgwColGlvf/ZNYAjJDstbSPcDoTIROfGBfSDm
	4VliQC82g==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gw6di-0007i1-S2; Tue, 19 Feb 2019 14:44:54 +0000
Date: Tue, 19 Feb 2019 06:44:54 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Jan Kara <jack@suse.cz>
Cc: Meelis Roos <mroos@linux.ee>, "Theodore Y. Ts'o" <tytso@mit.edu>,
	linux-alpha@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	linux-block@vger.kernel.org, linux-mm@kvack.org
Subject: Re: ext4 corruption on alpha with 4.20.0-09062-gd8372ba8ce28
Message-ID: <20190219144454.GB12668@bombadil.infradead.org>
References: <fb63a4d0-d124-21c8-7395-90b34b57c85a@linux.ee>
 <1c26eab4-3277-9066-5dce-6734ca9abb96@linux.ee>
 <076b8b72-fab0-ea98-f32f-f48949585f9d@linux.ee>
 <20190216174536.GC23000@mit.edu>
 <e175b885-082a-97c1-a0be-999040a06443@linux.ee>
 <20190218120209.GC20919@quack2.suse.cz>
 <4e015688-8633-d1a0-308b-ba2a78600544@linux.ee>
 <20190219132026.GA28293@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190219132026.GA28293@quack2.suse.cz>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 19, 2019 at 02:20:26PM +0100, Jan Kara wrote:
> Thanks for information. Yeah, that makes somewhat more sense. Can you ever
> see the failure if you disable CONFIG_TRANSPARENT_HUGEPAGE? Because your
> findings still seem to indicate that there' some problem with page
> migration and Alpha (added MM list to CC).

Could
https://lore.kernel.org/linux-mm/20190219123212.29838-1-larper@axis.com/T/#u
be relevant?

