Message-ID: <3FC4767B.6050401@gmx.de>
Date: Wed, 26 Nov 2003 10:46:35 +0100
From: "Prakash K. Cheemplavam" <prakashpublic@gmx.de>
MIME-Version: 1.0
Subject: Re: 2.6.0-test10-mm1
References: <20031125211518.6f656d73.akpm@osdl.org>
In-Reply-To: <20031125211518.6f656d73.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

without setting readahead higher then default. Now I must set it to 
10096 to get about the same performance (though not quite reaching 
it:25mb/sec, with 20mb/sec at defaults). Tested with hdparm.

Prakash

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
