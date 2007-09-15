Subject: Re: VM/VFS bug with large amount of memory and file systems?
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <C9A68AAE-0B37-4BB5-A9E6-66C186566940@cam.ac.uk>
References: <C2A8AED2-363F-4131-863C-918465C1F4E1@cam.ac.uk>
	 <1189850897.21778.301.camel@twins>
	 <C9A68AAE-0B37-4BB5-A9E6-66C186566940@cam.ac.uk>
Content-Type: text/plain
Date: Sat, 15 Sep 2007 13:19:01 +0200
Message-Id: <1189855141.21778.307.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Anton Altaparmakov <aia21@cam.ac.uk>
Cc: marc.smith@esmail.mcc.edu, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, 2007-09-15 at 11:50 +0100, Anton Altaparmakov wrote:
> Hi,
> 
> Thanks for looking into this.
> 
> On 15 Sep 2007, at 11:08, Peter Zijlstra wrote:
> > On Sat, 2007-09-15 at 08:27 +0100, Anton Altaparmakov wrote:
> >
> > Please, don't word wrap log-files, they're hard enough to read without
> > it :-(
> >
> > ( I see people do this more and more often, *WHY*? is that because we
> > like 80 char lines, in code and email? )
> 
> I haven't word wrapped it at all.  The lines appear as whole lines in  
> Apple Mail (my email client).  It must be your email client that is  
> wrapping them...
> 
> > Anyway, looks like all of zone_normal is pinned in kernel allocations:
> >
> >> Sep 13 15:31:25 escabot Normal free:3648kB min:3744kB low:4680kB  
> >> high: 5616kB active:0kB inactive:3160kB present:894080kB  
> >> pages_scanned:5336 all_unreclaimable? yes
> >

Oddly, this line is still long in Andrew's reply but wrapped in yours.
Must be some odd mailer interaction.

/me apologises.

I guess I really have to start looking for a hackable GUI email client
that has semi proper IMAP support.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
