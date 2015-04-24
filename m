Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id 1677D6B0032
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 14:56:49 -0400 (EDT)
Received: by qcpm10 with SMTP id m10so30724130qcp.3
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 11:56:48 -0700 (PDT)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [2001:558:fe21:29:69:252:207:35])
        by mx.google.com with ESMTPS id c41si12167236qge.65.2015.04.24.11.56.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 24 Apr 2015 11:56:47 -0700 (PDT)
Date: Fri, 24 Apr 2015 13:56:45 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Interacting with coherent memory on external devices
In-Reply-To: <20150424171957.GE3840@gmail.com>
Message-ID: <alpine.DEB.2.11.1504241353280.11285@gentwo.org>
References: <20150422163135.GA4062@gmail.com> <alpine.DEB.2.11.1504221206080.25607@gentwo.org> <1429756456.4915.22.camel@kernel.crashing.org> <alpine.DEB.2.11.1504230925250.32297@gentwo.org> <20150423161105.GB2399@gmail.com> <alpine.DEB.2.11.1504240912560.7582@gentwo.org>
 <20150424150829.GA3840@gmail.com> <alpine.DEB.2.11.1504241052240.9889@gentwo.org> <20150424164325.GD3840@gmail.com> <alpine.DEB.2.11.1504241148420.10475@gentwo.org> <20150424171957.GE3840@gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, paulmck@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Fri, 24 Apr 2015, Jerome Glisse wrote:

> > Right this is how things work and you could improve on that. Stay with the
> > scheme. Why would that not work if you map things the same way in both
> > environments if both accellerator and host processor can acceess each
> > others memory?
>
> Again and again share address space, having a pointer means the same thing
> for the GPU than it means for the CPU ie having a random pointer point to
> the same memory whether it is accessed by the GPU or the CPU. While also
> keeping the property of the backing memory. It can be share memory from
> other process, a file mmaped from disk or simply anonymous memory and
> thus we have no control whatsoever on how such memory is allocated.

Still no answer as to why is that not possible with the current scheme?
You keep on talking about pointers and I keep on responding that this is a
matter of making the address space compatible on both sides.

> Then you had transparent migration (transparent in the sense that we can
> handle CPU page fault on migrated memory) and you will see that you need
> to modify the kernel to become aware of this and provide a common code
> to deal with all this.

If the GPU works like a CPU (which I keep hearing) then you should also be
able to run a linu8x kernel on it and make it a regular NUMA node. Hey why
dont we make the host cpu a GPU (hello Xeon Phi).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
