Subject: Re: [PATCH] Recent VM fiasco - fixed
References: <Pine.LNX.4.10.10005101708590.1489-100000@penguin.transmeta.com>
From: Christoph Rohland <cr@sap.com>
Date: 11 May 2000 13:12:15 +0200
In-Reply-To: Linus Torvalds's message of "Wed, 10 May 2000 17:16:05 -0700 (PDT)"
Message-ID: <qwwwvl1733k.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "James H. Cloos Jr." <cloos@jhcloos.com>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Linus Torvalds <torvalds@transmeta.com> writes:

> Ok, there's a pre7-9 out there, and the biggest change versus pre7-8 is
[...]
> Just the dirty buffer handling made quite an enormous difference, so
> please do test this if you hated earlier pre7 kernels.

# vmstat 5
9   3  0     0 921884   1796  12776   0   0     0     0  108 77813   2  90   8
11  1  1 12044 523248   1080  25232   0 2494     0   624  327 16323   1  97   3
13  0  1 16468 728120    720  29000   0 3818     0   955  364 17820   3  97   0
11  1  1   336 237340    720  13040   0 1114     0   278  200 10402   1  99   0
10  2  1   476  41628    720  13184   0 4066     0  1017  401  5792   1  99   0
VM: killing process ipctst
VM: killing process ipctst
VM: killing process ipctst
4  5  1  31872   2500     96  25592  22 13447     6  3362  983 10863   0  82  1
5  4  1  58708 675260    280  19024   0 5388    12  1355 2231  1558   0  77  23
0  0  0  58708 675260    280  19024   0   0     0     0  112     4   0   0 100

I still hate it ;-)

Greetings
		Christoph
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
