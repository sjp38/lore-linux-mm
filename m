Date: Wed, 7 Jun 2000 20:53:55 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: reiserfs being part of the kernel: it's not just the code
Message-ID: <20000607205355.D30951@redhat.com>
References: <Pine.LNX.4.10.10006060811120.15888-100000@dax.joh.cam.ac.uk> <393CA40C.648D3261@reiser.to> <20000606114851.A30672@home.ds9a.nl> <393CBBB8.554A0D2A@reiser.to> <20000606172606.I25794@redhat.com> <393D37D1.1BC61DC3@reiser.to> <20000606205447.T23701@redhat.com> <393DACC8.5DB60A81@reiser.to> <20000607120030.D29432@redhat.com> <393E8A68.8DA3F4AB@reiser.to>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <393E8A68.8DA3F4AB@reiser.to>; from hans@reiser.to on Wed, Jun 07, 2000 at 10:46:16AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hans Reiser <hans@reiser.to>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, bert hubert <ahu@ds9a.nl>, linux-kernel@vger.rutgers.edu, Chris Mason <mason@suse.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Jun 07, 2000 at 10:46:16AM -0700, Hans Reiser wrote:
> 
> Have the FS stall if the limit is reached, and if the limit is reached, increase
> memory pressure invoking the mechanism that will drive allocate on flush.
> 
> The FS needs a lot of code, VFS needs something around ten lines, yes?

It's not the VFS as much as the VM which needs the work.  For example,
currently we have no way of exerting flow control on processes generating
dirty pages via mmap(), and fixing that requires work in the page fault
path.

> None of the ReiserFS team will be there.  I can see you at the UK thing, I know
> you are planning on going there.

OK, will you be bringing any other folks there?  

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
