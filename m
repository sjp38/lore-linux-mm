Subject: Re: Process not given >890MB on a 4MB machine ?????????
References: <5D2F375D116BD111844C00609763076E050D164D@exch-staff1.ul.ie>
	<20010920165622.B22441@redhat.com>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 21 Sep 2001 02:29:48 -0600
In-Reply-To: <20010920165622.B22441@redhat.com>
Message-ID: <m1sndh7xqb.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@redhat.com>
Cc: "Gabriel.Leen" <Gabriel.Leen@ul.ie>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Benjamin LaHaise <bcrl@redhat.com> writes:

> On Thu, Sep 20, 2001 at 08:25:37PM +0100, Gabriel.Leen wrote:
> > Hello,
> > The problem in a nutshell is:
> >
> > a) I have a 4GB ram 1.7Gh Xeon box
> > b) I'm running a process which requires around 3GB of ram
> > c) RedHat 2.4.9 will only give it 890MB, then core dumps with the warning
> > "segmentation fault"
> > when it reaches this memory usage and "asks for more"
>
> That's a limitation of the current memory layout.  If you compile your
> program statically (gcc -static), then you should be able to use closer
> to 3GB.

But note the maximum possible memory usage for a single process on x86 with 2.4.x
is 3GB...

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
