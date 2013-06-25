Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 406EE6B0031
	for <linux-mm@kvack.org>; Tue, 25 Jun 2013 10:24:34 -0400 (EDT)
Message-ID: <1372170272.18733.201.camel@gandalf.local.home>
Subject: Re: [3.11 1/4] slub: Make cpu partial slab support configurable V2
From: Steven Rostedt <rostedt@goodmis.org>
Date: Tue, 25 Jun 2013 10:24:32 -0400
In-Reply-To: <CAOJsxLHsYVThWL7yKEQaQqxTSpgK8RHm-u8n94t_m4=uMjDqzw@mail.gmail.com>
References: <20130614195500.373711648@linux.com>
	 <0000013f44418a14-7abe9784-a481-4c34-8ff3-c3afe2d57979-000000@email.amazonses.com>
	 <51BFFFA1.8030402@kernel.org>
	 <0000013f57a5b278-d9104e1e-ccec-40ec-bd95-f8b0816a38d9-000000@email.amazonses.com>
	 <20130618102109.310f4ce1@riff.lan>
	 <CAOJsxLHsYVThWL7yKEQaQqxTSpgK8RHm-u8n94t_m4=uMjDqzw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Clark Williams <williams@redhat.com>, Christoph Lameter <cl@linux.com>, Thomas Gleixner <tglx@linutronix.de>, Joonsoo Kim <js1304@gmail.com>, Clark Williams <clark@redhat.com>, Glauber Costa <glommer@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>

On Tue, 2013-06-18 at 18:25 +0300, Pekka Enberg wrote:
> On Tue, Jun 18, 2013 at 6:21 PM, Clark Williams <williams@redhat.com> wrote:
> > I'm sure it would be better to actually do cpu_partial processing in
> > small chunks to avoid latency spikes in latency sensitive applications
> 
> Sounds like a patch I'd be much more interested in applying...

Is this going to happen, otherwise we would really like a fix for RT.

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
