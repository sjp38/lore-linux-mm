Message-ID: <4638394F.60609@yahoo.com.au>
Date: Wed, 02 May 2007 17:10:07 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: 2.6.21-rc7-mm2 crash: Eeek! page_mapcount(page) went negative!
 (-1)
References: <20070425225716.8e9b28ca.akpm@linux-foundation.org>	<46338AEB.2070109@imap.cc>	<20070428141024.887342bd.akpm@linux-foundation.org>	<4636248E.7030309@imap.cc>	<20070430112130.b64321d3.akpm@linux-foundation.org>	<46364346.6030407@imap.cc> <20070430124638.10611058.akpm@linux-foundation.org> <46383742.9050503@imap.cc>
In-Reply-To: <46383742.9050503@imap.cc>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tilman Schmidt <tilman@imap.cc>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Greg Kroah-Hartman <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

Tilman Schmidt wrote:
> Am 30.04.2007 21:46 schrieb Andrew Morton:
> 
>>Not really - everything's tangled up.  A bisection search on the
>>2.6.21-rc7-mm2 driver tree would be the best bet.
> 
> 
> And the winner is:
> 
> gregkh-driver-driver-core-make-uevent-environment-available-in-uevent-file.patch

+	struct kobject *top_kobj;
+	struct kset *kset;
+	char *envp[32];
+	char data[PAGE_SIZE];
+	char *pos;
+	int i;
+	size_t count = 0;
+	int retval;

... that seems like a lot of stack to be using.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
