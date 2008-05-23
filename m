From: Johannes Weiner <hannes@saeurebad.de>
Subject: Re: max_mapnr config option
References: <1207340609.26869.20.camel@nimitz.home.sr71.net>
	<20080407091756.GC17915@shadowen.org> <87iqyuhth2.fsf@saeurebad.de>
	<20080408105137.GD17915@shadowen.org>
	<20080523130935.GA23176@shadowen.org>
Date: Fri, 23 May 2008 21:52:12 +0200
In-Reply-To: <20080523130935.GA23176@shadowen.org> (apw@shadowen.org's message
	of "Fri, 23 May 2008 14:09:35 +0100")
Message-ID: <87bq2wol1v.fsf@saeurebad.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: apw@shadowen.org
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, Jeremy Fitzhardinge <jeremy@goop.org>
List-ID: <linux-mm.kvack.org>

Hi,

apw@shadowen.org writes:

> On Tue, Apr 08, 2008 at 11:51:38AM +0100, Andy Whitcroft wrote:
>> On Mon, Apr 07, 2008 at 12:03:53PM +0200, Johannes Weiner wrote:
>> > Hi,
>> > 
>> > Andy Whitcroft <apw@shadowen.org> writes:
>> > 
>> > > BUT.  Looking over the actual references, there is a lot of references
>> > > occuring out of show_mem implementations in the arches which may well break
>> > > unless they follow suit.  We also don't have any show_mem implementation
>> > > for sparsemem.  I will have a look at what can be trivially cleaned
>> > > up here.
>> > 
>> > Perhaps you might be interested in http://lkml.org/lkml/2008/4/4/ .
>> 
>> How annoying is that, you have done the same thing I've just done.  I'll
>> look at your version and base off that.
>
> Whatever happened to this series.  I don't see it committed anywhere.
> Do you have a latest stack I could rebase my max_mapnr fixes off?

I rebased it against Linus' current tree.  Not all parts of the `remove
redundant output of free swap space' series have yet trickled into
upstream, so what I give you includes that (it is minimal and should
have been part of this series in the first place).

When all of the previous series hit mainline I will repost this one.

Here is the quilt series:

  http://saeurebad.de/patches/generic-show_mem.tar

or unpacked without the `.tar'-suffix.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
