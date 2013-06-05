Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 6E2C86B0085
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 19:29:39 -0400 (EDT)
Date: Wed, 5 Jun 2013 20:29:33 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH] virtio_balloon: leak_balloon(): only tell host if we got
 pages deflated
Message-ID: <20130605232932.GA30387@optiplex.redhat.com>
References: <20130605171031.7448deea@redhat.com>
 <20130605212449.GB19617@optiplex.redhat.com>
 <20130605190844.1e96bbde@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130605190844.1e96bbde@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org

On Wed, Jun 05, 2013 at 07:08:44PM -0400, Luiz Capitulino wrote:
> On Wed, 5 Jun 2013 18:24:49 -0300
> Rafael Aquini <aquini@redhat.com> wrote:
> 
> > On Wed, Jun 05, 2013 at 05:10:31PM -0400, Luiz Capitulino wrote:
> > > The balloon_page_dequeue() function can return NULL. If it does for
> > > the first page being freed, then leak_balloon() will create a
> > > scatter list with len=0. Which in turn seems to generate an invalid
> > > virtio request.
> > > 
> > > Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>
> > > ---
> > > 
> > > PS: I didn't get this in practice. I found it by code review. On the other
> > >     hand, automatic-ballooning was able to put such invalid requests in
> > >     the virtqueue and QEMU would explode...
> > >
> > 
> > Nice catch! The patch looks sane and replicates the check done at
> > fill_balloon(). I think we also could use this P.S. as a commentary 
> > to let others aware of this scenario. Thanks Luiz!
> 
> Want me to respin?
>

That would be great, indeed. I guess the commentary could also go for the same
if case at fill_balloon(), assuming the tests are placed to prevent the same
scenario you described at changelog. You can stick my Ack on it, if reposting.

Cheers!
-- Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
