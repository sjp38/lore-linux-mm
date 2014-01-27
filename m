Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f177.google.com (mail-yk0-f177.google.com [209.85.160.177])
	by kanga.kvack.org (Postfix) with ESMTP id AA0F56B0031
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 08:26:50 -0500 (EST)
Received: by mail-yk0-f177.google.com with SMTP id 19so10487388ykq.8
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 05:26:50 -0800 (PST)
Received: from mail.parisc-linux.org (palinux.external.hp.com. [192.25.206.14])
        by mx.google.com with ESMTPS id v1si8621263yhg.224.2014.01.27.05.26.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 27 Jan 2014 05:26:49 -0800 (PST)
Date: Mon, 27 Jan 2014 06:26:45 -0700
From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [PATCH v5 10/22] Remove get_xip_mem
Message-ID: <20140127132644.GB20939@parisc-linux.org>
References: <cover.1389779961.git.matthew.r.wilcox@intel.com> <557203b474f633a59f32fee1f624a5239effcab7.1389779961.git.matthew.r.wilcox@intel.com> <52D739F4.8060108@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52D739F4.8060108@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org

On Wed, Jan 15, 2014 at 05:46:28PM -0800, Randy Dunlap wrote:
> > +In order to support this method, the storage must be byte-accessable by
> 
>                                                         byte-accessible

Thanks.  Fixed.

> > +- ensuring that there is sufficient locking between reads, writes,
> > +  truncates and page faults
> 
>      truncates, and
> but that's up to you and your editor/proofreader etc.  :)

Ooh, do we really get to have a discussion about the Oxford Comma on
linux-kernel?  :-)

I haven't actually run this material past my editor (who is my wife, so
I need really convincing arguments to do it your way instead of hers),
but funnily we had a conversation about the Oxford Comma while on holiday
last week.  http://en.wikipedia.org/wiki/Serial_comma has a reasonably
exhaustive discourse on the subject, and I learned that she's probably
primarily against it because of her journalism degree.

> > +Even if the kernel or its modules are stored on an filesystem that supports
> 
>                                                    a

Good catch.  I think I started out with 'an fs', then expanded it to
"an filesystem" which of course is nonsense.

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
