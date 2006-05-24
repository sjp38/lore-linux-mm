Date: Wed, 24 May 2006 11:58:20 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [5/5] move_pages: 32bit support (i386,x86_64 and ia64)
Message-Id: <20060524115820.633708cf.akpm@osdl.org>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F0693FC5B@scsmsx401.amr.corp.intel.com>
References: <B8E391BBE9FE384DAA4C5C003888BE6F0693FC5B@scsmsx401.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: clameter@sgi.com, hugh@veritas.com, linux-ia64@vger.kernel.org, a.p.zijlstra@chello.nl, lee.schermerhorn@hp.com, nickpiggin@yahoo.com.au, linux-mm@kvack.org, ak@suse.de, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

"Luck, Tony" <tony.luck@intel.com> wrote:
>
> > 2. There is a whole range of syscalls missing for ia64 that I basically
> >   interpolated from elsewhere.
> 
> I've been thinking of dropping CONFIG_IA32_SUPPORT completely from ia64.
> I've heard no complaints that new syscalls are not being added to the
> ia32 compat side ... which is an indication that people are not
> actively using this.  Some OSDs have been building with this
> turned off for a while now (perhaps in preparation for "Montecito"
> which no longer has h/w support for the x86 instruction set, or
> perhaps because it represnts a huge block of lightly/barely tested
> code that will have its share of support issues).
> 
> I suppose I should do this by adding an entry to
>  Documentation/feature-removal-schedule.txt

I don't think people actively look in there.  You'd also need to do
something like mark it CONFIG_BROKEN, which will wake people up and might
make them go look to see what happened.  Updating the now-BROKEN help text
would make that nice and easy for them.

> Any thoughts on the timeline for this?  Is Dec 31, 2006 too soon?
> (or not soon enough!?).

You'd know better than we..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
