Date: Thu, 30 Oct 2008 10:45:45 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: SLUB defrag pull request?
In-Reply-To: <1225191983.27477.16.camel@penberg-laptop>
Message-ID: <Pine.LNX.4.64.0810301044290.20953@quilx.com>
References: <1223883004.31587.15.camel@penberg-laptop>
 <84144f020810221348j536f0d84vca039ff32676e2cc@mail.gmail.com>
 <E1Ksksa-0002Iq-EV@pomaz-ex.szeredi.hu>  <Pine.LNX.4.64.0810221416130.26639@quilx.com>
  <E1KsluU-0002R1-Ow@pomaz-ex.szeredi.hu>  <1224745831.25814.21.camel@penberg-laptop>
  <E1KsviY-0003Mq-6M@pomaz-ex.szeredi.hu>  <Pine.LNX.4.64.0810230638450.11924@quilx.com>
  <84144f020810230658o7c6b3651k2d671aab09aa71fb@mail.gmail.com>
 <Pine.LNX.4.64.0810230705210.12497@quilx.com>
 <84144f020810230714g7f5d36bas812ad691140ee453@mail.gmail.com>
 <Pine.LNX.4.64.0810230721400.12497@quilx.com>  <49009575.60004@cosmosbay.com>
  <Pine.LNX.4.64.0810231035510.17638@quilx.com>  <4900A7C8.9020707@cosmosbay.com>
  <Pine.LNX.4.64.0810231145430.19239@quilx.com>  <4900B0EF.2000108@cosmosbay.com>
 <1225191983.27477.16.camel@penberg-laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Eric Dumazet <dada1@cosmosbay.com>, Miklos Szeredi <miklos@szeredi.hu>, nickpiggin@yahoo.com.au, hugh@veritas.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, 28 Oct 2008, Pekka Enberg wrote:

> Christoph, I was sort of expecting a NAK/ACK from you before merging
> this. I would be nice to have numbers on this but then again I don't see
> how this can hurt either.

Its an additional instruction in a hot path. Lets see some numbers first.

Try tbench. Seems to be very popular recently. Or my microbenchmarks 
for slab allocations on kernel.org.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
