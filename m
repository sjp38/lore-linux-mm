Date: Sun, 3 Sep 2000 21:13:23 +0300 (EET DST)
From: Aki M Laukkanen <amlaukka@cc.helsinki.fi>
Subject: Re: [PATCH *] VM patch w/ drop behind for 2.4.0-test8-pre1
In-Reply-To: <Pine.OSF.4.20.0009031753510.27587-100000@sirppi.helsinki.fi>
Message-ID: <Pine.OSF.4.20.0009032108140.18719-100000@sirppi.helsinki.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 3 Sep 2000, Aki M Laukkanen wrote:
> I seem to have severe troubles with the VM patch although I'm not
> so sure it is the culprit. I'm running a t8-p1 kernel with vm2,
> sard (for 2.4.0-t5 but applied without faults) + streamfs on SMP.

Ok, it seems partly a false alert. I tried combinations streamfs+vmpatch 
and sard+streamfs. Both worked just fine so the combination of vmpatch
and sard patch seemed to trigger the problems.

http://www.cs.helsinki.fi/u/amlaukka/streamfs/hdrbench30x10-vmpatch2.png

It seems the drop-behind stuff is still not very tuned. Compare with 
hdrbench30x10.png and you'll see the difference. Infact hdrbench aborted
the test because of buffer overflows.

-- 
D.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
