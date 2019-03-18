Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E535CC43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 00:03:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 728552086A
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 00:03:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="WTfjylv7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 728552086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D5F476B0003; Sun, 17 Mar 2019 20:03:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D0EC96B0006; Sun, 17 Mar 2019 20:03:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD66D6B0007; Sun, 17 Mar 2019 20:03:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9E1856B0003
	for <linux-mm@kvack.org>; Sun, 17 Mar 2019 20:03:27 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id 77so11529889qkd.9
        for <linux-mm@kvack.org>; Sun, 17 Mar 2019 17:03:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=5brKLR3Vqjme6TUXB85RDO3aHvQ61CuyZtJW5QH7Sh8=;
        b=OTeFq/PB9mRGMpBqxcvr+jRi43yh26yGmQAgk9Zn8yF0ocr8LoCSj8wFxLC7Ezolwl
         RIYWc+/BAqChNT6ksa/FB/s1CospQ+q2SpV7+jiXcFqHzDlvzOSGfr+oqSrNhovgd8eH
         Q4u+v8iOjUEXpzpRWl8o/JlkxvbNorKQV+qum00OVwEPMLv/Tk/y2rgirhjhWE+WpQY5
         /diL4VhxoNYsnMUHJqAXPV+BeJZkCnTbgY9uSj4mFOGWkcLch9NwbCl/xx/VXHTeanmb
         /6UPLubUDflYgIrsQvbEnBdKjRQE9JKxLv2IlBkGKp92X+Nn1zp3Nto8WoY9D5aMrskr
         6j6w==
X-Gm-Message-State: APjAAAUQAz1BCLlWiwtN3lBSNZwfhbYuxqQGOJFMrTjWiOSHQdWDYx0W
	hYB2eEYfL/u/IMTApvlG0Bod6fefT37xYDf/AD7RsjcesZoyaPwS7GTYjlRLiPDyMNe6NJoBpi5
	QigbbgPcnuUlBxwe6Rm5h1E2rzUOxoJaJVwB8BDO3KTLs7DVBS91kctzbsjN35r0=
X-Received: by 2002:ac8:2246:: with SMTP id p6mr8383261qtp.225.1552867407327;
        Sun, 17 Mar 2019 17:03:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwaFNrArquHMjGE8iIvUmAPoiXAfbL3+h02EJz8ZqhruOreBxI1qfgN9PrhEeNOe0l5BA1S
X-Received: by 2002:ac8:2246:: with SMTP id p6mr8383206qtp.225.1552867406097;
        Sun, 17 Mar 2019 17:03:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552867406; cv=none;
        d=google.com; s=arc-20160816;
        b=HnbXEXgImroDGfBmVVbdUk8FIXTtwSMcFxkChfq5sPbqPo6wxrOfaY8/ZppOWsKKu8
         JdaMgZ45LEiBLkSrTotPH4icF35gKWUKsI5I3zddlzjPAV7/Jvp0CALeQKDZyKKGjC5h
         amN0p7JQ4mjBtjHrjI06dPLw77nRyjffMr0R6a/TTJKrVr22vk4GSn7/MQaIWsLwjDvX
         mSmamCqzOz6TE2TAfXsLirw40xZtc3nCHZjS7Bpi7IW8irSzePX3HlJKqrXJN/x1cNuu
         Pi1Q2PIEW1reggF2m2fSmi6HbETV9rZ7LA5djO81H49S6fas82MUKVPOiMX8QuAbxR3X
         ixtw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=5brKLR3Vqjme6TUXB85RDO3aHvQ61CuyZtJW5QH7Sh8=;
        b=GziOqmYQYHd/P5B+8gSOuDz0+l9aAmlfnQNQ0lqns0WfPXjSCUJH/v4PjgqJFlmLzq
         qgtzqmO8ucahM2wvP0D+RTBjdzjKzSrQiHYg2v0UEP5zdrYqbC98CVSDHKxSS9KNdS0J
         /V71rjn2MyXo/MmIX1zB7QF9zEGLvykgY84Smhg6A6Pq2DSSqMftRvf7bVeax6lD0V0D
         PRDoaXNqaFISMe3kW20eMUQ/xixJpS2XIzAyUZrxkkUGy/0fJ4QIcFXZD4v8RMNubsu5
         oIxPkwsjlMesDWk72IAFvPshshbkQ/v93Z6sxtL/nrHslQyU7KJwT6yZoVaYb1eUUuGz
         URIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=WTfjylv7;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id f43si678384qtf.106.2019.03.17.17.03.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Mar 2019 17:03:26 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=WTfjylv7;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 27FD4216AC;
	Sun, 17 Mar 2019 20:03:25 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Sun, 17 Mar 2019 20:03:25 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:message-id:mime-version:subject:to:x-me-proxy:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=5brKLR3Vqjme6TUXB
	85RDO3aHvQ61CuyZtJW5QH7Sh8=; b=WTfjylv7dQbdHZaxnCl+sVfRIFJLgtpdB
	g7Gvae1lFf0sn/qpVQepvSt6gOTZXgrSX0QBVmxL0zbQJALcUULaESbRyxL/PlUT
	hwqMMOKnfVDFF+hDUd9koBdGoktCUonpvYcaGeT9OV41R+ybXOkvYUQw/qVMlBup
	5K/7kcuXAPRv9sYpwAqRK+AtvmW/k36wJG3TOOtxRaO6Wruob6QRA/PUV6rBDchH
	mRR0i2lAAQiCYAVgbhbXXZQP1YQrLta7pH3tuv2UGFGW9fHA5be0FcNMrlkPHGS4
	9yz1KE8KC+Uzo/g7uK/yX5Cvo+ri8ze1c2uwrJQeSIwgHd3y2qaLA==
X-ME-Sender: <xms:S-COXIBG4-FoeBZJIYbV6ft70L6fa_HEQnjYrAouruQn6M1AbTF7XA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddriedtgddukecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhnucev
    rdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucffohhmrg
    hinhepghhithhhuhgsrdgtohhmnecukfhppeduudekrddvuddurdduleelrdduvdeinecu
    rfgrrhgrmhepmhgrihhlfhhrohhmpehtohgsihhnsehkvghrnhgvlhdrohhrghenucevlh
    hushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:S-COXGTug3YYoAo23RV0-UY7FRUcWENAXlSIRzppFKhwe3JbI59erg>
    <xmx:S-COXPKNKw083_oexn695NxClsC_FhavvLan_mr9m4u3DqIVQ2qTbg>
    <xmx:S-COXKdxUqnxwME43loun2Tem7aoyffTbHuVHjsbJpxPXYZvTRvOJA>
    <xmx:TeCOXLEXr4LgR0DvVUPeJwkJ11t9N7zEagsF9PmgDPtwaqcJ3YSlKA>
Received: from eros.localdomain (ppp118-211-199-126.bras1.syd2.internode.on.net [118.211.199.126])
	by mail.messagingengine.com (Postfix) with ESMTPA id 86676E4684;
	Sun, 17 Mar 2019 20:03:20 -0400 (EDT)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Roman Gushchin <guro@fb.com>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v4 0/7] mm: Use slab_list list_head instead of lru
Date: Mon, 18 Mar 2019 11:02:27 +1100
Message-Id: <20190318000234.22049-1-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

v4 fixes patch 3 (change _all_ instances of ->lru to ->slab_list) as
noticed by Roman.  Built, booted, and tested with the test modules
mentioned below.

Roman,

I kept your reviewed-by tag on patch 3 since functionally its the same
patch (and the additional changes were pointed out by you :).  Thanks.


From v3 ...

Currently the slab allocators (ab)use the struct page 'lru' list_head.
We have a list head for slab allocators to use, 'slab_list'.

During v2 it was noted by Christoph that the SLOB allocator was reaching
into a list_head, this version adds 2 patches to the front of the set to
fix that.

Clean up all three allocators by using the 'slab_list' list_head instead
of overloading the 'lru' list_head.

Patch 1 - Adds a function to rotate a list to a specified entry.

Patch 2 - Removes the code that reaches into list_head and instead uses
	  the list_head API including the newly defined function.

Patches 3-7 are unchanged from v3

Patch 3 (v2: patch 4) - Changes the SLOB allocator to use slab_list
      	     	      	instead of lru.

Patch 4 (v2: patch 1) - Makes no code changes, adds comments to #endif
      	     	      	statements.

Patch 5 (v2: patch 2) - Use slab_list instead of lru for SLUB allocator.

Patch 6 (v2: patch 3) - Use slab_list instead of lru for SLAB allocator.

Patch 7 (v2: patch 5) - Removes the now stale comment in the page struct
      	     	      	definition.

During v2 development patches were checked to see if the object file
before and after was identical.  Clearly this will no longer be possible
for mm/slob.o, however this work is still of use to validate the
change from lru -> slab_list.

Patch 1 was tested with a module (creates and populates a list then
calls list_rotate_to_front() and verifies new order):

      https://github.com/tcharding/ktest/tree/master/list_head

Patch 2 was tested with another module that does some basic slab
allocation and freeing to a newly created slab cache:

	https://github.com/tcharding/ktest/tree/master/slab

Tested on a kernel with this in the config:

	CONFIG_SLOB=y
	CONFIG_SLAB_MERGE_DEFAULT=y

Changes since v3:

 - Change all ->lru to ->slab_list in slob (thanks Roman).

Changes since v2:

 - Add list_rotate_to_front().
 - Fix slob to use list_head API.
 - Re-order patches to put the list.h changes up front.
 - Add acks from Christoph.

Changes since v1:

 - Verify object files are the same before and after the patch set is
   applied (suggested by Matthew).
 - Add extra explanation to the commit logs explaining why these changes
   are safe to make (suggested by Roman).
 - Remove stale comment (thanks Willy).


thanks,
Tobin.


Tobin C. Harding (7):
  list: Add function list_rotate_to_front()
  slob: Respect list_head abstraction layer
  slob: Use slab_list instead of lru
  slub: Add comments to endif pre-processor macros
  slub: Use slab_list instead of lru
  slab: Use slab_list instead of lru
  mm: Remove stale comment from page struct

 include/linux/list.h     | 18 ++++++++++++
 include/linux/mm_types.h |  2 +-
 mm/slab.c                | 49 ++++++++++++++++----------------
 mm/slob.c                | 32 +++++++++++++--------
 mm/slub.c                | 60 ++++++++++++++++++++--------------------
 5 files changed, 94 insertions(+), 67 deletions(-)

-- 
2.21.0

