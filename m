Date: Tue, 14 May 2002 09:54:14 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [RFC][PATCH] iowait statistics
Message-ID: <20020514165414.GC27957@holomorphy.com>
References: <20020514153956.GI15756@holomorphy.com> <Pine.LNX.4.44L.0205141335080.9490-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44L.0205141335080.9490-100000@duckman.distro.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 14 May 2002, William Lee Irwin III wrote:
>> This appears to be global across all cpu's. Maybe nr_iowait_tasks
>> should be accounted on a per-cpu basis, where

On Tue, May 14, 2002 at 01:36:00PM -0300, Rik van Riel wrote:
> While your proposal should work, somehow I doubt it's worth
> the complexity. It's just a statistic to help sysadmins ;)

I reserved judgment on that in order to present a possible mechanism.
I'm not sure it is either; we'll know it matters if sysadmins scream.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
