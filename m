Received: by nf-out-0910.google.com with SMTP id b2so898675nfe
        for <linux-mm@kvack.org>; Sun, 18 Mar 2007 16:13:37 -0700 (PDT)
Message-ID: <21d7e9970703181613h7ed6625fl9ab7d05a56f4c998@mail.gmail.com>
Date: Mon, 19 Mar 2007 10:13:37 +1100
From: "Dave Airlie" <airlied@gmail.com>
Subject: Re: [patch 0/6] fault vs truncate/invalidate race fix
In-Reply-To: <1172559262.11949.47.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070221023656.6306.246.sendpatchset@linux.site>
	 <21d7e9970702262036h3575229ex3bf3cd4474a57068@mail.gmail.com>
	 <20070226213204.14f8b584.akpm@linux-foundation.org>
	 <21d7e9970702262226v6fc70e06jd759c66c383630e1@mail.gmail.com>
	 <1172559262.11949.47.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, npiggin@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> > the new fault hander made the memory manager code a lot cleaner and
> > very less hacky in a lot of cases. so I'd rather merge the clean code
> > than have to fight with the current code...
>
> Note that you can probably get away with NOPFN_REFAULT etc... like I did
> for the SPEs in the meantime.

Indeed, Thomas has done this work and I'm just lining up a TTM tree to
start the merge process..

Dave.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
