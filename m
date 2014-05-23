From: Pekka Enberg <penberg@iki.fi>
Subject: Re: slab_common: fix the check for duplicate slab names
Date: Sat, 24 May 2014 00:28:15 +0300
Message-ID: <537FBD6F.1070009@iki.fi>
References: <alpine.LRH.2.02.1403041711300.29476@file01.intranet.prod.int.rdu2.redhat.com> <20140325170324.GC580@redhat.com> <alpine.DEB.2.10.1403251306260.26471@nuc> <20140523201632.GA16013@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140523201632.GA16013@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Mike Snitzer <snitzer@redhat.com>, Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, linux-kernel@vger.kernel.org, "Alasdair G. Kergon" <agk@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>
List-Id: linux-mm.kvack.org

On 05/23/2014 11:16 PM, Mike Snitzer wrote:
> On Tue, Mar 25 2014 at  2:07pm -0400,
> Christoph Lameter <cl@linux.com> wrote:
>
>> On Tue, 25 Mar 2014, Mike Snitzer wrote:
>>
>>> This patch still isn't upstream.  Who should be shepherding it to Linus?
>> Pekka usually does that.
>>
>> Acked-by: Christoph Lameter <cl@linux.com>
> This still hasn't gotten upstream.
>
> Pekka, any chance you can pick it up?  Here it is in dm-devel's
> kernel.org patchwork: https://patchwork.kernel.org/patch/3768901/
>
> (Though it looks like it needs to be rebased due to the recent commit
> 794b1248, should Mikulas rebase and re-send?)

I applied it and fixed the conflict by hand.

Please double-check commit 694617474e33b8603fc76e090ed7d09376514b1a in 
my tree:

https://git.kernel.org/cgit/linux/kernel/git/penberg/linux.git/

- Pekka
