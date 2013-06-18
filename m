Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 07F696B0033
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 11:25:48 -0400 (EDT)
Received: by mail-wg0-f53.google.com with SMTP id y10so3656008wgg.32
        for <linux-mm@kvack.org>; Tue, 18 Jun 2013 08:25:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130618102109.310f4ce1@riff.lan>
References: <20130614195500.373711648@linux.com>
	<0000013f44418a14-7abe9784-a481-4c34-8ff3-c3afe2d57979-000000@email.amazonses.com>
	<51BFFFA1.8030402@kernel.org>
	<0000013f57a5b278-d9104e1e-ccec-40ec-bd95-f8b0816a38d9-000000@email.amazonses.com>
	<20130618102109.310f4ce1@riff.lan>
Date: Tue, 18 Jun 2013 18:25:47 +0300
Message-ID: <CAOJsxLHsYVThWL7yKEQaQqxTSpgK8RHm-u8n94t_m4=uMjDqzw@mail.gmail.com>
Subject: Re: [3.11 1/4] slub: Make cpu partial slab support configurable V2
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Clark Williams <williams@redhat.com>
Cc: Christoph Lameter <cl@linux.com>, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>, Joonsoo Kim <js1304@gmail.com>, Clark Williams <clark@redhat.com>, Glauber Costa <glommer@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>

On Tue, Jun 18, 2013 at 6:21 PM, Clark Williams <williams@redhat.com> wrote:
> I'm sure it would be better to actually do cpu_partial processing in
> small chunks to avoid latency spikes in latency sensitive applications

Sounds like a patch I'd be much more interested in applying...

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
