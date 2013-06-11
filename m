Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 9FF4F6B0033
	for <linux-mm@kvack.org>; Tue, 11 Jun 2013 09:13:20 -0400 (EDT)
Received: by mail-wi0-f177.google.com with SMTP id ey16so4113232wid.16
        for <linux-mm@kvack.org>; Tue, 11 Jun 2013 06:13:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130611062124.GA24031@dhcp22.suse.cz>
References: <021701ce65cb$a3b9c3b0$eb2d4b10$%kim@samsung.com>
	<20130610151258.GA14295@dhcp22.suse.cz>
	<20130611001747.GA16971@teo>
	<20130611062124.GA24031@dhcp22.suse.cz>
Date: Tue, 11 Jun 2013 16:13:18 +0300
Message-ID: <CAOJsxLF8TCCLJWaNrydEatcYgj49ChBsNLJXpMaUTfRywUMm9w@mail.gmail.com>
Subject: Re: [PATCH] memcg: event control at vmpressure.
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Anton Vorontsov <anton@enomsg.org>, Hyunhee Kim <hyunhee.kim@samsung.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Kyungmin Park <kyungmin.park@samsung.com>

On Tue, Jun 11, 2013 at 9:21 AM, Michal Hocko <mhocko@suse.cz> wrote:
>> Or, if you still want the "one-shot"/"edge-triggered" events (which might
>> make perfect sense for medium and critical levels), then I'd propose to
>> add some additional flag when you register the event, so that the old
>> behaviour would be still available for those who need it. This approach I
>> think is the best one.
>
> Hmm, how would one-shot even differ from a single open, register, read
> and close?

Yup, one-shot probably doesn't make sense but edge-triggered does.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
