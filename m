Date: Thu, 7 Jun 2001 17:38:39 +0200 (CEST)
From: Mike Galbraith <mikeg@wen-online.de>
Subject: Re: Break 2.4 VM in five easy steps
In-Reply-To: <OF75B67BC7.4C70DAF5-ON85256A64.004C4AD1@pok.ibm.com>
Message-ID: <Pine.LNX.4.33.0106071641020.332-100000@mikeg.weiden.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bulent Abali <abali@us.ibm.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Derek Glidden <dglidden@illusionary.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 7 Jun 2001, Bulent Abali wrote:

> I happened to saw this one with debugger attached serial port.
> The system was alive.  I think I was watching the free page count and
> it was decreasing very slowly may be couple pages per second.  Bigger
> the swap usage longer it takes to do swapoff.  For example, if I had
> 1GB in the swap space then it would take may be an half hour to shutdown...

I took a ~300ms ktrace snapshot of the no IO spot with 2.4.4.ikd..

  % TOTAL    TOTAL USECS    AVG/CALL   NCALLS
  0.0693%         208.54        0.40      517 c012d4b9 __free_pages
  0.0755%         227.34        1.01      224 c012cb67 __free_pages_ok
  ...
 34.7195%      104515.15        0.95   110049 c012de73 unuse_vma
 53.3435%      160578.37      303.55      529 c012dd38 __swap_free
Total entries: 131051  Total usecs:    301026.93 Idle: 0.00%

Andrew Morton could be right about that loop not being wonderful.

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
