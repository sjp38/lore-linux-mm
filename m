Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id DA9646B0038
	for <linux-mm@kvack.org>; Tue, 16 May 2017 01:57:04 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id l73so61536963pfj.8
        for <linux-mm@kvack.org>; Mon, 15 May 2017 22:57:04 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b21si13141815pgn.66.2017.05.15.22.57.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 May 2017 22:57:04 -0700 (PDT)
Date: Tue, 16 May 2017 07:56:52 +0200
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: Low memory killer problem
Message-ID: <20170516055652.GA25379@kroah.com>
References: <AF7C0ADF1FEABA4DABABB97411952A2EDD0A004D@CN-MBX05.HTC.COM.TW>
 <AF7C0ADF1FEABA4DABABB97411952A2EDD0A4F06@CN-MBX03.HTC.COM.TW>
 <20170515080535.GA22076@kroah.com>
 <AF7C0ADF1FEABA4DABABB97411952A2EDD0A4F84@CN-MBX03.HTC.COM.TW>
 <20170515090027.GA18167@kroah.com>
 <AF7C0ADF1FEABA4DABABB97411952A2EDD0A52C9@CN-MBX03.HTC.COM.TW>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AF7C0ADF1FEABA4DABABB97411952A2EDD0A52C9@CN-MBX03.HTC.COM.TW>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhiyuan_zhu@htc.com
Cc: vinmenon@codeaurora.org, linux-mm@kvack.org, skhiani@codeaurora.org, torvalds@linux-foundation.org, Jet_Li@htc.com

On Tue, May 16, 2017 at 03:41:31AM +0000, zhiyuan_zhu@htc.com wrote:
> Thanks for your remind,
> I found lowmemorykiller.c have been removed, and ION module still exist since v4.12-rc1.
> I will pay attention to ION module.
> 
> But I still have 3 questions,
> Is there any substitute for low-memory-killer after kernel v4.12-rc1 ?

See the email thread when it was removed, there was some proposals on
how to do this "correctly".  I know someone at Google is currently
working on this, hopefully they have something to post soon about it.

> Can I accounted the ION free to free memory?
> Is there any different from ION free and the normal system memory free?

No idea, try asking the ION developers :)

good luck!

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
