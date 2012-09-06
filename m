Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id DF3FE6B009E
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 21:07:39 -0400 (EDT)
Received: by iec9 with SMTP id 9so2621320iec.14
        for <linux-mm@kvack.org>; Wed, 05 Sep 2012 18:07:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1209051752060.7625@chino.kir.corp.google.com>
References: <1346885323-15689-1-git-send-email-elezegarcia@gmail.com>
	<alpine.DEB.2.00.1209051752060.7625@chino.kir.corp.google.com>
Date: Wed, 5 Sep 2012 22:07:39 -0300
Message-ID: <CALF0-+XtBe49vs5LM68Q+7YbRbNV-+LQRuNSgq_S12frbYC_Bw@mail.gmail.com>
Subject: Re: [PATCH 1/5] mm, slab: Remove silly function slab_buffer_size()
From: Ezequiel Garcia <elezegarcia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

On Wed, Sep 5, 2012 at 9:54 PM, David Rientjes <rientjes@google.com> wrote:
> On Wed, 5 Sep 2012, Ezequiel Garcia wrote:
>
>> This function is seldom used, and can be simply replaced with cachep->size.
>>
>
> You didn't remove the declaration of this function in the header file.

Yes, you're right.

Thanks for reviewing,
Ezequiel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
