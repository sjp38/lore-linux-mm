Date: Sun, 3 Apr 2005 15:37:36 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: AIM9 slowdowns between 2.6.11 and 2.6.12-rc1
Message-ID: <Pine.LNX.4.58.0504031532570.25594@skynet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

While testing the page placement policy patches on 2.6.12-rc1, I noticed
that aim9 is showing significant slowdowns on page allocation-related
tests. An excerpt of the results is at the end of this mail but it shows
that page_test is allocating 18000 less pages.

I did not check who has been recently changing the buddy allocator but
they might want to run a benchmark or two to make sure this is not
something specific to my setup.

root@monocle:~# grep _test vmregressbench-2.6.11-standard/aim9/log.txt
     7 page_test           60.01       4420   73.65439       125212.46 System Allocations & Pages/second
     8 brk_test            60.00       1732   28.86667       490733.33 System Memory Allocations/second
     9 jmp_test            60.01     252898 4214.26429      4214264.29 Non-local gotos/second
    10 signal_test         60.00       5983   99.71667        99716.67 Signal Traps/second
    11 exec_test           60.01        788   13.13114           65.66 Program Loads/second
    12 fork_test           60.06        986   16.41692         1641.69 Task Creations/second
    13 link_test           60.00       6302  105.03333         6617.10 Link/Unlink Pairs/second
root@monocle:~# grep _test vmregressbench-2.6.12-rc1-standard/aim9/log.txt
     7 page_test           60.01       3784   63.05616       107195.47 System Allocations & Pages/second
     8 brk_test            60.02       1194   19.89337       338187.27 System Memory Allocations/second
     9 jmp_test            60.00     252312 4205.20000      4205200.00 Non-local gotos/second
    10 signal_test         60.00       3731   62.18333        62183.33 Signal Traps/second
    11 exec_test           60.08        762   12.68309           63.42 Program Loads/second
    12 fork_test           60.04        864   14.39041         1439.04 Task Creations/second
    13 link_test           60.01       4723   78.70355         4958.32 Link/Unlink Pairs/second

-- 
Mel Gorman
Part-time Phd Student                          Java Applications Developer
University of Limerick                         IBM Dublin Software Lab
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
