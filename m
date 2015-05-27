Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 0B9AE6B0120
	for <linux-mm@kvack.org>; Tue, 26 May 2015 22:34:18 -0400 (EDT)
Received: by pdfh10 with SMTP id h10so104411972pdf.3
        for <linux-mm@kvack.org>; Tue, 26 May 2015 19:34:17 -0700 (PDT)
Received: from out5-smtp.messagingengine.com (out5-smtp.messagingengine.com. [66.111.4.29])
        by mx.google.com with ESMTPS id np6si23510459pbc.250.2015.05.26.19.34.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 May 2015 19:34:17 -0700 (PDT)
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 57C0C20A44
	for <linux-mm@kvack.org>; Tue, 26 May 2015 22:34:14 -0400 (EDT)
Date: Tue, 26 May 2015 19:34:12 -0700
From: Greg KH <greg@kroah.com>
Subject: Re: [RFC v2 1/4] fs: Add generic file system event notifications
Message-ID: <20150527023412.GA20070@kroah.com>
References: <20150428135653.GD9955@quack.suse.cz>
 <20150428140936.GA13406@kroah.com>
 <553F9D56.6030301@samsung.com>
 <20150428173900.GA16708@kroah.com>
 <5540822C.10000@samsung.com>
 <20150429074259.GA31089@quack.suse.cz>
 <20150429091303.GA4090@kroah.com>
 <5548B4BB.7050503@samsung.com>
 <554B5329.8040907@samsung.com>
 <5564A1D4.4040309@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5564A1D4.4040309@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Beata Michalska <b.michalska@samsung.com>
Cc: Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org, tytso@mit.edu, adilger.kernel@dilger.ca, hughd@google.com, lczerner@redhat.com, hch@infradead.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com, kmpark@infradead.org

On Tue, May 26, 2015 at 06:39:48PM +0200, Beata Michalska wrote:
> Hi,
> 
> Things has gone a bit quiet thread wise ...
> As I believe I've managed to snap back to reality, I was hoping we could continue with this?
> I'm not sure if we've got everything cleared up or ... have we reached a dead end?
> Please let me know if we can move to the next stage? Or, if there are any showstoppers?

Please resend if you think it's ready and you have addressed the issues
raised so far.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
