Date: Sat, 23 Sep 2000 20:15:38 CEST
From: Uman <Uman@editec-lotteries.com>
Subject: possible mistake in kswapd
Reply-To: Uman@editec-lotteries.com
MIME-Version: 1.0
Content-Type: text/plain; charset="koi8-r"
Content-Transfer-Encoding: 8bit
Message-Id: <20000925090320Z131165-10811+38@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


hello.
please look in vmscan.c kswapd function.
in time_after(  ){
recalc=jiffie;
recalculate_vm_stats();
}
variable recalc defined inside  for loop, 
so each time we got time_after(jiffie,0+HZ) it's always true so
i suppose under heavy load we'll execute recalculate_vm_stat each time
we come to kswapd , as i understand we just loose to many time for
recalculating memory stat.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
