Date: Tue, 14 May 2002 11:19:26 -0700
From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Subject: Re: [RFC][PATCH] iowait statistics
Message-ID: <37930000.1021400366@flay>
In-Reply-To: <Pine.LNX.4.44L.0205141335080.9490-100000@duckman.distro.conectiva>
References: <Pine.LNX.4.44L.0205141335080.9490-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, William Lee Irwin III <wli@holomorphy.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> This appears to be global across all cpu's. Maybe nr_iowait_tasks
>> should be accounted on a per-cpu basis, where
> 
> While your proposal should work, somehow I doubt it's worth
> the complexity. It's just a statistic to help sysadmins ;)

Depends how often you're going to end up bouncing that cacheline 
around ... do you do this for every IO?

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
