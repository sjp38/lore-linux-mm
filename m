From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14126.56807.620332.813094@dukat.scot.redhat.com>
Date: Tue, 4 May 1999 12:45:43 +0100 (BST)
Subject: Re: Hello
In-Reply-To: <19970101162919.58637@fred.muc.de>
References: <001901be9324$66ddcbf0$c80c17ac@clmsdev.local>
	<14120.65431.754233.47675@dukat.scot.redhat.com>
	<19970101162919.58637@fred.muc.de>
Sender: owner-linux-mm@kvack.org
To: ak@muc.de
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Manfred Spraul <masp0008@stud.uni-sb.de>, "Benjamin C.R. LaHaise" <blah@kvack.org>, "James E. King, III" <jking@ariessys.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, 1 Jan 1997 16:29:19 +0100, ak@muc.de said:
   ^^^^^^^^^^^^^^^

??? Check your clocks!

> On Fri, Apr 30, 1999 at 02:55:51AM +0200, Stephen C. Tweedie wrote:

>> NT's VLM support only gives you access to the high memory if you use a
>> special API.  We plan on supporting clean access to all of physical
>> memory quite transparently for Linux, without any such restrictions.

> Not even the restriction that a single process cannot use more than 
> 4GB-something?

The high memory support will have no new restrictions visible to the
user.  The existing 3GB virtual address space limit will not be
changed.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
