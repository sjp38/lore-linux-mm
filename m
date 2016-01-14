Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 1E727828DF
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 09:40:20 -0500 (EST)
Received: by mail-ig0-f174.google.com with SMTP id h5so129200358igh.0
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 06:40:20 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0147.hostedemail.com. [216.40.44.147])
        by mx.google.com with ESMTPS id m76si13175910iod.36.2016.01.14.06.40.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jan 2016 06:40:19 -0800 (PST)
Date: Thu, 14 Jan 2016 09:40:07 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [RFC V5] Add gup trace points support
Message-ID: <20160114094007.5b5c6e4d@gandalf.local.home>
In-Reply-To: <56969400.6020805@linaro.org>
References: <1449696151-4195-1-git-send-email-yang.shi@linaro.org>
	<56955B76.2060503@linaro.org>
	<20160112151052.168bba85@gandalf.local.home>
	<56969400.6020805@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: "Shi, Yang" <yang.shi@linaro.org>, mingo@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org


Andrew,

Do you want to pull in this series? You can add my Acked-by to the whole
set.

-- Steve


On Wed, 13 Jan 2016 10:14:24 -0800
"Shi, Yang" <yang.shi@linaro.org> wrote:

> On 1/12/2016 12:10 PM, Steven Rostedt wrote:
> > On Tue, 12 Jan 2016 12:00:54 -0800
> > "Shi, Yang" <yang.shi@linaro.org> wrote:
> >  
> >> Hi Steven,
> >>
> >> Any more comments on this series? How should I proceed it?
> >>  
> >
> > The tracing part looks fine to me. Now you just need to get the arch
> > maintainers to ack each of the arch patches, and I can pull them in for
> > 4.6. Too late for 4.5. Probably need Andrew Morton's ack for the
> > mm/gup.c patch.  
> 
> Thanks Steven. Already sent email to x86, s390 and sparc maintainers. 
> Ralf already acked the MIPS part since v1.
> 
> Regards,
> Yang
> 
> >
> > -- Steve
> >  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
