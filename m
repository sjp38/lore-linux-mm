Message-ID: <46925B5D.8000507@google.com>
Date: Mon, 09 Jul 2007 08:59:25 -0700
From: Martin Bligh <mbligh@google.com>
MIME-Version: 1.0
Subject: Re: [patch 00/10] [RFC] SLUB patches for more functionality, performance
 and maintenance
References: <20070708034952.022985379@sgi.com> <p73y7hrywel.fsf@bingen.suse.de> <Pine.LNX.4.64.0707090845520.13792@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0707090845520.13792@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Sun, 8 Jul 2007, Andi Kleen wrote:
> 
>> Christoph Lameter <clameter@sgi.com> writes:
>>
>>> A cmpxchg is less costly than interrupt enabe/disable
>> That sounds wrong.
> 
> Martin Bligh was able to significantly increase his LTTng performance 
> by using cmpxchg. See his article in the 2007 proceedings of the OLS 
> Volume 1, page 39.
> 
> His numbers were:
> 
> interrupts enable disable : 210.6ns
> local cmpxchg             : 9.0ns

Those numbers came from Mathieu Desnoyers (LTTng) if you
want more details.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
