From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14126.56540.689629.191667@dukat.scot.redhat.com>
Date: Tue, 4 May 1999 12:41:16 +0100 (BST)
Subject: Re: Hello
In-Reply-To: <004201be93da$e9c15df0$c80c17ac@clmsdev.local>
References: <004201be93da$e9c15df0$c80c17ac@clmsdev.local>
Sender: owner-linux-mm@kvack.org
To: Manfred Spraul <masp0008@stud.uni-sb.de>
Cc: ak@muc.de, "Benjamin C.R. LaHaise" <blah@kvack.org>, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Sat, 1 May 1999 16:00:01 +0200, "ak@muc.de" <ak@muc.de> said:

> Due to the 32 bit addressing, you can't use more that 4 Gb memory
> at the same time.
> I think you could create several memory mapped regions,
> each e.g. 1 GB and map one at a time. 

Indeed, and that is what (for example) NT's VLM allows.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
