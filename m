Received: by nf-out-0910.google.com with SMTP id c2so286835nfe
        for <linux-mm@kvack.org>; Tue, 07 Nov 2006 15:08:54 -0800 (PST)
Message-ID: <12c511ca0611071508x1630ca54x72994336ecc7a6d6@mail.gmail.com>
Date: Tue, 7 Nov 2006 15:08:53 -0800
From: "Tony Luck" <tony.luck@intel.com>
Subject: Re: default base page size on ia64 processor
In-Reply-To: <53f38ab60611062345m6cfeda14v4f1f809fe55e95ef@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <53f38ab60611062345m6cfeda14v4f1f809fe55e95ef@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: adheer chandravanshi <adheerchandravanshi@gmail.com>
Cc: kernelnewbies <kernelnewbies@nl.linux.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Can anyone tell me what is the default base page size supported  by
> ia64 processor on Linux?

Default page size for Itanium is 16K

> And can we change the base page size to some large page size like 16kb,64kb....?
> and how to do that?

You need to rebuild the kernel to change the default pagesize.  Run
"make menuconfig"
and choose the "Processor type and features" menu entry, 3rd entry
down on that menu
is "Kernel page size".  You can choose 4k, 8k, 16k or 64k.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
