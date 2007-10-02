Received: by ug-out-1314.google.com with SMTP id a2so22288ugf
        for <linux-mm@kvack.org>; Tue, 02 Oct 2007 16:03:27 -0700 (PDT)
Message-ID: <3d8471ca0710021603x2288fbe9h78e3568235140d7c@mail.gmail.com>
Date: Wed, 3 Oct 2007 01:03:26 +0200
From: "Guillaume Chazarain" <guichaz@yahoo.fr>
Subject: Re: [PATCH] Handle errors in sync_sb_inodes()
In-Reply-To: <20071003005706.0fbacb94@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20071003005706.0fbacb94@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> +               mapping_set_error(mapping, ret);

And of course, s/ret/err/ :-(

-- 
Guillaume

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
