Subject: Re: 2.5.68-mm2
From: Alex Tomas <bzzz@tmi.comex.ru>
Date: Wed, 23 Apr 2003 19:14:32 +0400
In-Reply-To: <18400000.1051109459@[10.10.2.4]> (Martin J. Bligh's message of
 "Wed, 23 Apr 2003 07:51:00 -0700")
Message-ID: <m3r87t8cvb.fsf@tmi.comex.ru>
References: <20030423012046.0535e4fd.akpm@digeo.com>
	<18400000.1051109459@[10.10.2.4]>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
Cc: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> Martin J Bligh (MJB) writes:

 >> . I got tired of the objrmap code going BUG under stress, so it is now in
 >> disgrace in the experimental/ directory.

 MJB> Any chance of some more info on that? BUG at what point in the code,
 MJB> and with what test to reproduce?

I've seen this running fsx-linux on ext3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
