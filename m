Date: Tue, 21 May 2002 11:45:09 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: lazy buddy prototype
Message-ID: <20020521184509.GG2046@holomorphy.com>
References: <20020521175005.GN2035@holomorphy.com> <20020521183628.GF2046@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <20020521183628.GF2046@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2002 at 10:50:05AM -0700, William Lee Irwin III wrote:
>> TODO:
> [...]
>> (13) figure out some way to get fragmentation stats out of the buddy bitmap

On Tue, May 21, 2002 at 11:36:28AM -0700, William Lee Irwin III wrote:
> And an important omission, of which Andrew Morton reminded me:
> (14) document it

and from Ben LaHaise:

(15) collect statistics on the allocation rates for various orders

and concomitant to this:

(16) collect statistics on allocation failures due to fragmentation


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
