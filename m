Received: by an-out-0708.google.com with SMTP id d33so971804and
        for <linux-mm@kvack.org>; Wed, 30 May 2007 17:35:57 -0700 (PDT)
Message-ID: <a8e1da0705301735r5619f79axcb3ea6c7dd344efc@mail.gmail.com>
Date: Thu, 31 May 2007 00:35:56 +0000
From: "young dave" <hidave.darkstar@gmail.com>
Subject: Re: [RFC 1/4] CONFIG_STABLE: Define it
In-Reply-To: <20070531003012.302019683@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070531002047.702473071@sgi.com>
	 <20070531003012.302019683@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "clameter@sgi.com" <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Hi Christoph,

>Introduce CONFIG_STABLE to control checks only useful for development.

What about control checks only as SLUB_DEBUG is set?

Regards
dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
