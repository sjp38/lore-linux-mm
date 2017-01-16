Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4875E6B0038
	for <linux-mm@kvack.org>; Sun, 15 Jan 2017 19:19:59 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id n189so64021717pga.4
        for <linux-mm@kvack.org>; Sun, 15 Jan 2017 16:19:59 -0800 (PST)
Received: from mail-pf0-x22e.google.com (mail-pf0-x22e.google.com. [2607:f8b0:400e:c00::22e])
        by mx.google.com with ESMTPS id d24si19759810plj.113.2017.01.15.16.19.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 15 Jan 2017 16:19:58 -0800 (PST)
Received: by mail-pf0-x22e.google.com with SMTP id 189so48627738pfu.3
        for <linux-mm@kvack.org>; Sun, 15 Jan 2017 16:19:58 -0800 (PST)
Message-ID: <1484525991.27533.31.camel@dubeyko.com>
Subject: Re: [LSF/MM TOPIC] Future direction of DAX
From: Viacheslav Dubeyko <slava@dubeyko.com>
Date: Sun, 15 Jan 2017 16:19:51 -0800
In-Reply-To: <20170114082621.GC10498@birch.djwong.org>
References: <20170114002008.GA25379@linux.intel.com>
	 <20170114082621.GC10498@birch.djwong.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@ml01.01.org, linux-block@vger.kernel.org, linux-mm@kvack.org

On Sat, 2017-01-14 at 00:26 -0800, Darrick J. Wong wrote:

<skipped>

> Some day we'll start designing a pmem-native fs, I guess. :P

There are research efforts in this direction already ([1]-[15]). The
latest one is NOVA, as far as I can see. But, frankly speaking, I
believe that we need in new hardware paradigm/architecture and new OS
paradigm for the next generation of NVM memory. The DAX is
simpleA palliative, temporary solution. But, from my point of view,
pmem-native fs is also not good direction because, anyway, memory
subsystem will be affected significantly. And, finally, evolution of
memory subsystem will reveal something completely different that we can
imagine right now.

Thanks,
Vyacheslav Dubeyko.A 

[1]A http://pages.cs.wisc.edu/~swift/papers/eurosys14-aerie.pdf
[2]A https://www.researchgate.net/publication/282792714_A_User-Level_File_System_for_Fast_Storage_Devices
[3] https://people.eecs.berkeley.edu/~dcoetzee/publications/Better%20IO%20Through%20Byte-Addressable,%20Persistent%20Memory.pdf
[4] https://www.computer.org/csdl/proceedings/msst/2013/0217/00/06558440.pdf
[5] https://users.soe.ucsc.edu/~scott/papers/MASCOTS04b.pdf
[6] http://ieeexplore.ieee.org/document/4142472/
[7] https://cseweb.ucsd.edu/~swanson/papers/FAST2016NOVA.pdf
[8] http://cesg.tamu.edu/wp-content/uploads/2012/02/MSST13.pdf
[9] http://ieeexplore.ieee.org/document/5487498/
[10] https://pdfs.semanticscholar.org/544c/1ddf24b90c3dfba7b1934049911b869c99b4.pdf
[11] http://pramfs.sourceforge.net/tech.html
[12] https://pdfs.semanticscholar.org/2981/b5abcbe1023b9f3cd962b0be7ef8bd45acfd.pdf
[13] http://ieeexplore.ieee.org/document/6232378/
[14] http://ieeexplore.ieee.org/document/7304365/
[15] http://ieeexplore.ieee.org/document/6272446/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
