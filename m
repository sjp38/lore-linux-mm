From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH -mm -v4 1/3] i386/x86_64 boot: setup data
Date: Tue, 9 Oct 2007 13:13:44 +0200
References: <1191912010.9719.18.camel@caritas-dev.intel.com> <200710090125.27263.nickpiggin@yahoo.com.au>
In-Reply-To: <200710090125.27263.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Disposition: inline
Message-Id: <200710091313.45003.ak@suse.de>
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: "Huang, Ying" <ying.huang@intel.com>, linux-mm@kvack.org, "H. Peter Anvin" <hpa@zytor.com>, "Eric W. Biederman" <ebiederm@xmission.com>, akpm@linux-foundation.org, Yinghai Lu <yhlu.kernel@gmail.com>, Chandramouli Narayanan <mouli@linux.intel.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Care to add a line of documentation if you keep it in mm/memory.c?

It would be better to just use early_ioremap() (or ioremap())

That is how ACPI who has similar issues accessing its tables solves this.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
