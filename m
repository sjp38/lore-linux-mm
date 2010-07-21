Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 880BC6B024D
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 05:23:15 -0400 (EDT)
From: Christian Dietrich <stettberger@dokucode.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Dead Config in mm/percpu.c
Date: Wed, 21 Jul 2010 11:22:51 +0200
Message-ID: <861vaxjij8.fsf@peer.zerties.org>
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <tj@kernel.org>, David Howells <dhowells@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi all!
=20=20=20=20=20=20=20
        As part of the VAMOS[0] research project at the University of
Erlangen we are looking at multiple integrity errors in linux'
configuration system.

        I've been running a check on the mm/ sourcetree for
config Items not defined in Kconfig and found 1 such case. Sourcecode
blocks depending on these Items are not reachable from a vanilla
kernel -- dead code. I've seen such dead blocks made on purpose
e.g. while integrating new features into the kernel but generally
they're just useless.

We found, that CONFIG_NEED_PER_CPU_KM is a dead symbol, so it isn't defined
anywhere. Cause of that the percpu_km.c is never included anywhere. Is
this a intended dead symbol, for use in out of tree development, or is
this just an error?

Regards
        Christian Dietrich
--=20
(=CE=BB x . x x) (=CE=BB x . x x) -- See how beatiful the lambda is
No documentation is better than bad documentation
-- Das Ausdrucken dieser Mail wird urheberrechtlich verfolgt.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
