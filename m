Subject: Re: [patch 0/6] fault vs truncate/invalidate race fix
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <21d7e9970702262226v6fc70e06jd759c66c383630e1@mail.gmail.com>
References: <20070221023656.6306.246.sendpatchset@linux.site>
	 <21d7e9970702262036h3575229ex3bf3cd4474a57068@mail.gmail.com>
	 <20070226213204.14f8b584.akpm@linux-foundation.org>
	 <21d7e9970702262226v6fc70e06jd759c66c383630e1@mail.gmail.com>
Content-Type: text/plain
Date: Tue, 27 Feb 2007 07:54:22 +0100
Message-Id: <1172559262.11949.47.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Airlie <airlied@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, npiggin@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> the new fault hander made the memory manager code a lot cleaner and
> very less hacky in a lot of cases. so I'd rather merge the clean code
> than have to fight with the current code...

Note that you can probably get away with NOPFN_REFAULT etc... like I did
for the SPEs in the meantime.

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
