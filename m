Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 9F69B6B002F
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 13:43:52 -0400 (EDT)
Message-ID: <1318355030.8896.12.camel@Joe-Laptop>
Subject: Re: [PATCH] treewide: Use __printf not
 __attribute__((format(printf,...)))
From: Joe Perches <joe@perches.com>
Date: Tue, 11 Oct 2011 10:43:50 -0700
In-Reply-To: <20111011172208.GA3633@shutemov.name>
References: 
	<5a0bef0143ed2b3176917fdc0ddd6a47f4c79391.1314303846.git.joe@perches.com>
	 <20110825165006.af771ef7.akpm@linux-foundation.org>
	 <1314316801.19476.6.camel@Joe-Laptop>
	 <20110825170534.0d425c75.akpm@linux-foundation.org>
	 <1314319088.19476.17.camel@Joe-Laptop>
	 <20110825180734.9beae279.akpm@linux-foundation.org>
	 <1314327338.19476.30.camel@Joe-Laptop>
	 <20111011172208.GA3633@shutemov.name>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jiri Kosina <trivial@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org

On Tue, 2011-10-11 at 20:22 +0300, Kirill A. Shutemov wrote:
> On Thu, Aug 25, 2011 at 07:55:37PM -0700, Joe Perches wrote:
> > Standardize the style for compiler based printf format verification.
> > Standardized the location of __printf too.
> > Done via script and a little typing.
> > $ grep -rPl --include=*.[ch] -w "__attribute__" * | \
> >   grep -vP "^(tools|scripts|include/linux/compiler-gcc.h)" | \
> >   xargs perl -n -i -e 'local $/; while (<>) { s/\b__attribute__\s*\(\s*\(\s*format\s*\(\s*printf\s*,\s*(.+)\s*,\s*(.+)\s*\)\s*\)\s*\)/__printf($1, $2)/g ; print; }'
> > Completely untested...
> This patch breaks ARCH=um (linux-next-20111011):

Hi Kirill, thanks for reporting this.

I think it breaks almost all the the arches with modifications.

> In file included from /home/kas/git/public/linux-next/arch/um/os-Linux/aio.c:17:0:
> /home/kas/git/public/linux-next/arch/um/include/shared/user.h:26:17: error: expected declaration specifiers or a??...a?? before numeric constant

Hey Andrew, I think _all_ of the arch/... changes
except arch/frv and arch/s390 should be reverted.

Andrew, I don't know if you saw this:
https://lkml.org/lkml/2011/9/28/324


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
