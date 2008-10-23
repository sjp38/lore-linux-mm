Date: Thu, 23 Oct 2008 07:09:24 -0700 (PDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: SLUB defrag pull request?
In-Reply-To: <84144f020810230658o7c6b3651k2d671aab09aa71fb@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0810230705210.12497@quilx.com>
References: <1223883004.31587.15.camel@penberg-laptop>
 <Pine.LNX.4.64.0810221315080.26671@quilx.com>  <E1KskHI-0002AF-Hz@pomaz-ex.szeredi.hu>
  <84144f020810221348j536f0d84vca039ff32676e2cc@mail.gmail.com>
 <E1Ksksa-0002Iq-EV@pomaz-ex.szeredi.hu>  <Pine.LNX.4.64.0810221416130.26639@quilx.com>
  <E1KsluU-0002R1-Ow@pomaz-ex.szeredi.hu>  <1224745831.25814.21.camel@penberg-laptop>
  <E1KsviY-0003Mq-6M@pomaz-ex.szeredi.hu>  <Pine.LNX.4.64.0810230638450.11924@quilx.com>
 <84144f020810230658o7c6b3651k2d671aab09aa71fb@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Miklos Szeredi <miklos@szeredi.hu>, nickpiggin@yahoo.com.au, hugh@veritas.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, 23 Oct 2008, Pekka Enberg wrote:

> On Thu, Oct 23, 2008 at 4:40 PM, Christoph Lameter
> <cl@linux-foundation.org> wrote:
>> Solid? What is not solid? The SLUB design was made in part because of the
>> defrag problems that were not easy to solve with SLAB. The ability to lock
>> down a slab allows stabilizing objects. We discussed solutions to the
>> fragmentation problem for years and did not get anywhere with SLAB.
>
> I'd assume he's talking about the Intel-reported regression that's yet
> to be resolved.

On that subject:

Got a draft of a patch here that does freelist handling differently. 
Instead of building linked lists it uses free objects to build arrays of 
pointers to free objects. That improves cache cold free behavior since the 
object contents itself does not have to be touched on free.

The problem looks like its freeing objects on a different processor that 
where it was used last. With the pointer array it is only necessary to 
touch the objects that contain the arrays.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
