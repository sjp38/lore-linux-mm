From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14120.65431.754233.47675@dukat.scot.redhat.com>
Date: Fri, 30 Apr 1999 01:55:51 +0100 (BST)
Subject: Re: Hello
In-Reply-To: <001901be9324$66ddcbf0$c80c17ac@clmsdev.local>
References: <001901be9324$66ddcbf0$c80c17ac@clmsdev.local>
Sender: owner-linux-mm@kvack.org
To: Manfred Spraul <masp0008@stud.uni-sb.de>
Cc: "Benjamin C.R. LaHaise" <blah@kvack.org>, "James E. King, III" <jking@ariessys.com>, linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, 30 Apr 1999 18:12:21 +0200, "Manfred Spraul"
<masp0008@stud.uni-sb.de> said:

> * I haven't yet read the new Xeon page table extentions,
>   but perhaps we could support up to 64 GB memory without changing the
>   rest of the OS   (Intel could write such a driver for Windows NT,
>   I'm sure this is possible for Linux, too).

NT's VLM support only gives you access to the high memory if you use a
special API.  We plan on supporting clean access to all of physical
memory quite transparently for Linux, without any such restrictions.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
