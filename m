Subject: Re: temp. mem mappings
References: <3B289FA9@MailAndNews.com>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 25 Jun 2001 00:52:25 -0600
In-Reply-To: <3B289FA9@MailAndNews.com>
Message-ID: <m1y9qh9hli.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: cohutta <cohutta@MailAndNews.com>
Cc: "Joseph A. Knapka" <jknapka@earthlink.net>, "Stephen C. Tweedie" <sct@redhat.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

I don't know if this has been resolved but I believe the correct idiom
to read the ACPI table would be:
kmap(virt_to_page(phys_to_virt(address)));

And then kunmap it when you are done.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
