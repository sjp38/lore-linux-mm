Date: Thu, 10 Nov 2005 23:55:01 +0000 (GMT)
From: Anton Altaparmakov <aia21@cam.ac.uk>
Subject: Re: [RFC] sys_punchhole()
In-Reply-To: <1131666062.25354.41.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0511102351130.24857@hermes-1.csi.cam.ac.uk>
References: <1131664994.25354.36.camel@localhost.localdomain>
 <20051110153254.5dde61c5.akpm@osdl.org> <1131666062.25354.41.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, andrea@suse.de, hugh@veritas.com, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 10 Nov 2005, Badari Pulavarty wrote:
> On Thu, 2005-11-10 at 15:32 -0800, Andrew Morton wrote:
> > Badari Pulavarty <pbadari@us.ibm.com> wrote:
> > >
> > > We discussed this in madvise(REMOVE) thread - to add support 
> > > for sys_punchhole(fd, offset, len) to complete the functionality
> > > (in the future).
> > > 
> > > http://marc.theaimsgroup.com/?l=linux-mm&m=113036713810002&w=2
> > > 
> > > What I am wondering is, should I invest time now to do it ?
> > 
> > I haven't even heard anyone mention a need for this in the past 1-2 years.
> > 
> > > Or wait till need arises ? 
> > 
> > A long wait, I suspect..
> > 
> 
> Okay. I guess, I will wait till someone needs it.
> 
> I am just trying to increase my chances of "getting my madvise(REMOVE)
> patch into mainline" :)
> 

It may be worth asking the Samba people if they want it given that Windows 
has such a function (but it is not a syscall, it is a fsctl - 
FSCTL_SET_ZERO_DATA), so Samba may want to have it, too...

And in case you care, NTFS already has such functionality (currently only 
used in error handling) and implementing the sys_punchole() fs-specific 
function for ntfs will therefore be trivial...

Best regards,

	Anton
-- 
Anton Altaparmakov <aia21 at cam.ac.uk> (replace at with @)
Unix Support, Computing Service, University of Cambridge, CB2 3QH, UK
Linux NTFS maintainer / IRC: #ntfs on irc.freenode.net
WWW: http://linux-ntfs.sf.net/ & http://www-stu.christs.cam.ac.uk/~aia21/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
