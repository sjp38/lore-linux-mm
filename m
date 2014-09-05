Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 1A7BC6B0036
	for <linux-mm@kvack.org>; Fri,  5 Sep 2014 11:07:55 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id fp1so15974622pdb.27
        for <linux-mm@kvack.org>; Fri, 05 Sep 2014 08:07:54 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id k5si4752771pdn.89.2014.09.05.08.07.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Sep 2014 08:07:52 -0700 (PDT)
Message-ID: <5409D197.2060900@zytor.com>
Date: Fri, 05 Sep 2014 08:07:03 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] x86, mm, pat: Set WT to PA4 slot of PAT MSR
References: <1409855739-8985-1-git-send-email-toshi.kani@hp.com>	 <1409855739-8985-2-git-send-email-toshi.kani@hp.com>	 <20140904201123.GA9116@khazad-dum.debian.net> <5408C9C4.1010705@zytor.com>	 <20140904231923.GA15320@khazad-dum.debian.net>	 <CALCETrWxKFtM8FhnHQz--uaHYbiqShE1XLJxMCKN7Rs4SO14eQ@mail.gmail.com>	 <1409876991.28990.172.camel@misato.fc.hp.com>	 <CALCETrUhbx4hFRAkHfczLkZBYo0E7tRmdFyO7bqPd5e9JEWcMA@mail.gmail.com> <1409925614.28990.184.camel@misato.fc.hp.com>
In-Reply-To: <1409925614.28990.184.camel@misato.fc.hp.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>, Andy Lutomirski <luto@amacapital.net>
Cc: Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, akpm@linuxfoundation.org, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Juergen Gross <jgross@suse.com>, Stefan Bader <stefan.bader@canonical.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On 09/05/2014 07:00 AM, Toshi Kani wrote:
> 
> That's a fine idea, but as Ingo also suggested, I am going to disable
> this feature on all Pentium 4 models.  That should give us a safety
> margin.  Using slot 4 has a benefit that it keeps the PAT setup
> consistent with Xen.      
> 

Slot 4 is also the maximally problematic one, because it is the one that
might be incorrectly invoked for the page tables themselves.

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
