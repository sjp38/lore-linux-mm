Date: Wed, 14 Jun 2006 12:46:05 +0300
From: Gleb Natapov <gleb@minantech.com>
Subject: Re: vfork implementation...
Message-ID: <20060614094605.GC17758@minantech.com>
References: <BKEKJNIHLJDCFGDBOHGMGEEECPAA.abum@aftek.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BKEKJNIHLJDCFGDBOHGMGEEECPAA.abum@aftek.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Abu M. Muttalib" <abum@aftek.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 14, 2006 at 03:11:58PM +0530, Abu M. Muttalib wrote:
> Hi,
> 
> This mail is intended for Robert Love, I hope I can find him on the list.
> 
> Please refer to Pg 24 of chapter 2 of Linux Kernel Development.
> 
> As mentioned in the description of vfork call, it is said that child is not
> allowed to write to the address space, but in the following example its not
> so. The child is able to write to the process address space. This program
> was tested with Linux Kernel 2.6.9. Why is it so?
> 
Not allowed and not able are two different things.

> fork.c
> ----------------------------------------------------------------------------
> ---------------------------------------
> #include <stdio.h>
> 
> unsigned char *glob_var = NULL;
> 
> void main()
> {
> 	int pid = -8,i;
> 	pid = vfork();
> 
> 	if(pid < 0)
> 		printf("\n FORK ERROR \n");
> 
> 	if(pid == 0)
> 	{
> 		unsigned char * local_var = NULL;
> 		local_var = (unsigned char *)malloc(5);
> 		strcpy(local_var,"ABCD");
> 		glob_var = local_var;
> 		printf("\nCHILD :Value of glob_var is  %X local_var is %X glob_var is %c
> \n",glob_var,local_var,*glob_var);
> 		for(i=0;i<4;i++)
> 		{
> 			printf("\n CHAR is %c \n",glob_var[i]);
> 		}
> 		printf("\nCHILD1 :Value of glob_var is %X %c\n",glob_var,*(glob_var));
> 	}
> 
> 	if(pid > 0)
> 	{
> 		printf("\nParent : Value of glob_var is  %X %c\n",glob_var,*(glob_var));
> 		free(glob_var);
> 		printf("\nParent : Value of glob_var is %X %c\n",glob_var,*(glob_var));
> 		exit(0);
> 	}
> }
> ----------------------------------------------------------------------------
> ---------------------------------------
> 
> Regards,
> Abu.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
