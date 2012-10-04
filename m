Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 282FA6B00F5
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 06:23:01 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so524482pbb.14
        for <linux-mm@kvack.org>; Thu, 04 Oct 2012 03:23:00 -0700 (PDT)
Date: Thu, 4 Oct 2012 03:20:13 -0700
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: [PATCH 0/3] A few cleanups and refactorings, sync w/ upstream
Message-ID: <20121004102013.GA23284@lizard>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org

Hello Pekka,

Just a few updates to vmevents:

- Some cleanups and refactorings -- needed for easier integration of
  'memory pressure' work;
- Forward to newer Linus' tree, fix conflicts.

For convenience, the merge commit and all the patches can be pulled from
this repo:

	git://git.infradead.org/users/cbou/linux-vmevent.git tags/vmevent-updates

Thanks,
Anton.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
