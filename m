Subject: Re: [PATCH/RFC] Migrate-on-fault prototype 0/5 V0.1 - Overview
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Reply-To: lee.schermerhorn@hp.com
In-Reply-To: <Pine.LNX.4.64.0603091135200.17789@schroedinger.engr.sgi.com>
References: <1141928905.6393.10.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0603091104280.17622@schroedinger.engr.sgi.com>
	 <1141932602.6393.68.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0603091135200.17789@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Thu, 09 Mar 2006 15:14:43 -0500
Message-Id: <1141935283.6393.82.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2006-03-09 at 11:42 -0800, Christoph Lameter wrote:
> On Thu, 9 Mar 2006, Lee Schermerhorn wrote:
> 
> > I'm wondering if applications keep changing the policy as you describe
> > to "finesse" the system--e.g., because they don't have fine enough
> > control over the policies.  Perhaps I read it wrong, but it appears to
> > me that we can't set the policy for subranges of a vm area.  So maybe
> 
> We can set the policies for subranges. See mempolicy.c

Yow!  I see.  We split the vma.  I did look at this a while back to see
if I needed to worry about different policies on subranges of VMAs.
Came away realizing that I did not have to worry because each vma only
has a single policy.  Forgot about the splitting...   Hmmm, isn't a
vm_area_struct a rather heavy-weight policy container?  Oh well, at
least we can't exceed sysctl_max_map_count of them [64K by default] per
task/mm ;-).  And probably only applications on really big systems will
do this to any extent.  

Lee


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
