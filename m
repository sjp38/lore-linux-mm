Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 4ACAE6B0038
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 03:43:20 -0400 (EDT)
Received: by wigg3 with SMTP id g3so100212731wig.1
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 00:43:19 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id es2si1623674wib.12.2015.06.16.00.43.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 16 Jun 2015 00:43:18 -0700 (PDT)
Date: Tue, 16 Jun 2015 09:43:09 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Possible broken MM code in dell-laptop.c?
Message-ID: <20150616074308.GB24296@dhcp22.suse.cz>
References: <201506141105.07171@pali>
 <20150615211816.GC16138@dhcp22.suse.cz>
 <201506152327.59907@pali>
 <20150616063346.GA24296@dhcp22.suse.cz>
 <20150616071523.GB5863@pali>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20150616071523.GB5863@pali>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pali =?iso-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>
Cc: Darren Hart <dvhart@infradead.org>, Hans de Goede <hdegoede@redhat.com>, Ben Skeggs <bskeggs@redhat.com>, Stuart Hayes <stuart_hayes@dell.com>, Matthew Garrett <mjg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, platform-driver-x86@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 16-06-15 09:15:23, Pali Rohar wrote:
[...]
> Michal, thank you for explaining this situation!
> 
> Darren, I will prepare patch which will fix code and use __free_page().
> 
> (Btw, execution on fail_rfkill label caused kernel panic)

I am sorry, I could have made it more clear in the very first email.
A panic is to be expected because free_page will translate the given
address to a struct page* but this is what the code gave it. So an
unrelated struct page would be freed (or maybe an invalid one).

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
