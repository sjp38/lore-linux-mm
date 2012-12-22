Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 2C4B86B005A
	for <linux-mm@kvack.org>; Sat, 22 Dec 2012 03:29:38 -0500 (EST)
Date: Sat, 22 Dec 2012 03:29:33 -0500
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v2 2/3] mm: Update file times when inodes are written
 after mmaped writes
Message-ID: <20121222082933.GA26477@infradead.org>
References: <cover.1356124965.git.luto@amacapital.net>
 <6b22b806806b21af02b70a2fa860a9d10304fc16.1356124965.git.luto@amacapital.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6b22b806806b21af02b70a2fa860a9d10304fc16.1356124965.git.luto@amacapital.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>

NAK, we went through great trouble to get rid of the nasty layering
violation where the VM called file_update_time directly just a short
while ago, reintroducing that is a massive step back.

Make sure whatever "solution" for your problem you come up with keeps
the file update in the filesystem or generic helpers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
