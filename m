Date: Thu, 16 Jun 2005 15:58:38 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.6.12-rc6-mm1 & 2K lun testing
Message-ID: <20050616225838.GE3913@holomorphy.com>
References: <1118856977.4301.406.camel@dyn9047017072.beaverton.ibm.com> <20050616002451.01f7e9ed.akpm@osdl.org> <1118951458.4301.478.camel@dyn9047017072.beaverton.ibm.com> <20050616224230.GD3913@holomorphy.com> <1118960737.4301.483.camel@dyn9047017072.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1118960737.4301.483.camel@dyn9047017072.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2005-06-16 at 15:42, William Lee Irwin III wrote:
>> It's because you're sorting on the third field of readprofile(1),
>> which is pure gibberish. Undoing this mistake will immediately
>> enlighten you.

On Thu, Jun 16, 2005 at 03:25:42PM -0700, Badari Pulavarty wrote:
> Hmm.. I was under the impression that its gives useful info ..
> Here is readprofile man-page says:
>        Print the 20 most loaded procedures:
>           readprofile | sort -nr +2 | head -20

Unfortunately it's bunk. Sorting by hits gives a much better idea
of where the time is going because it corresponds to time. That's
done with readprofile | sort -nr +0 | head -20


On Thu, 2005-06-16 at 15:42, William Lee Irwin III wrote:
>> Also, turn off slab poisoning when doing performance analyses.
> Its already off. I am not trying to compare performance here.
> I was trying to analyze VM behaviour with filesystem tests.
> (with "raw" devices, machine is perfectly happy - but with
> filesystem cache it crawls).

check_poison_obj(), which appears in your profile, exists only when
CONFIG_DEBUG_SLAB is set.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
