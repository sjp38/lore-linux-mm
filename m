Date: Wed, 10 Feb 1999 14:25:24 GMT
Message-Id: <199902101425.OAA02586@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Large memory system
In-Reply-To: <003201be53a2$43d766f0$c80c17ac@clmsdev>
References: <003201be53a2$43d766f0$c80c17ac@clmsdev>
Sender: owner-linux-mm@kvack.org
To: Manfred Spraul <masp0008@stud.uni-sb.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "Benjamin C.R. LaHaise" <blah@kvack.org>, Daniel Blakeley <daniel@msc.cornell.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 8 Feb 1999 21:33:09 +0100, "Manfred Spraul"
<manfreds@colorfullife.com> said:

> There is another possibility if you want to extend the page cache:
> Add a 'second level cache':

The primary reason for adding more memory is for process anonymous
pages, not for cache, so this is really of limited value on its own.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
