Received: from flinx.npwt.net (eric@flinx.npwt.net [208.236.161.237])
	by kvack.org (8.8.7/8.8.7) with ESMTP id AAA29159
	for <linux-mm@kvack.org>; Sun, 26 Apr 1998 00:11:59 -0400
Subject: msync & MS_INVALIDATE question
From: ebiederm+eric@npwt.net (Eric W. Biederman)
Date: 25 Apr 1998 23:17:39 -0500
Message-ID: <m14szhmd24.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


The man page I have for msync(MS_INVALIDATE) says it should invalidate
all other mappings. I.e. get all other mappings.

The implementation does something quite different, that is related to
only the present mapping.

Was this a pure documentation bug.  Was MS_INVALIDATE not implemented
correctly because of no reverse maps?  Or is something else going on
here?

I know in the context of MAP_SHARED invalidating other mappings seems
like a reasonable proposition.

Eric
